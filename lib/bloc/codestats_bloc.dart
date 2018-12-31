import 'dart:async';
import 'dart:convert';
import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/models/pulse/pulse.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:hydrated/hydrated.dart';
import 'package:dio/dio.dart';
import 'package:codestats_flutter/queries.dart' as queries;
import 'package:codestats_flutter/utils.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:superpower/superpower.dart';
import 'package:rxdart/subjects.dart';

enum ValidUser { Unknown, Loading, Valid, Invalid, Error }

enum DataFetching { Done, Loading, Error }

class UserBloc implements BlocBase {
  UserState state = UserState.empty();
  static const baseUrl = "https://codestats.net";
  static const wsBaseUrl = "wss://codestats.net/live_update_socket/websocket";

  final socket = PhoenixSocket(wsBaseUrl,
      socketOptions: PhoenixSocketOptions(params: {"vsn": "2.0.0"}));
  final Dio _dio = Dio(
    Options(
      baseUrl: baseUrl,
    ),
  );

  HydratedSubject<String> _currentUserController =
      HydratedSubject<String>("currentUser", seedValue: "");

  StreamSink<String> get selectUser => _currentUserController.sink;

  Stream<String> get selectedUser => _currentUserController.stream;

  HydratedSubject<UserState> _userStateController;

  Stream<UserState> get users => _userStateController.stream;

  PublishSubject<ValidUser> _userValidationSubject = PublishSubject();

  Stream<ValidUser> get userValidation =>
      _userValidationSubject.stream.startWith(ValidUser.Unknown);

  StreamSink<ValidUser> get setUserValidation => _userValidationSubject.sink;

  BehaviorSubject<DataFetching> _dataFetchingSubject = BehaviorSubject();

  Stream<DataFetching> get dataFetching =>
      _dataFetchingSubject.stream.startWith(DataFetching.Done);

  StreamSink<DataFetching> get setDataFetching => _dataFetchingSubject.sink;

  PublishSubject<Map<String, dynamic>> _searchResultSubject = PublishSubject();

  Stream<Map<String, dynamic>> get searchResult => _searchResultSubject.stream;

  PublishSubject<String> _searchUserSubject = PublishSubject();

  StreamSink<String> get searchUser => _searchUserSubject;

  UserBloc() {
    _userStateController = HydratedSubject<UserState>("userState",
        hydrate: (s) {
          try {
            return UserState.fromJson(jsonDecode(s));
          } catch (e) {
            return UserState.empty();
          }
        },
        seedValue: UserState.empty(),
        persist: (state) => jsonEncode(state.toJson()),
        onHydrate: fetchAllUsers);

    _userStateController.listen(_setUserState);

    _searchUserSubject
        .distinct()
        .debounce(Duration(milliseconds: 500))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .listen(this._onSearchUser);

    setupDebugLog(_dio);

    assert(() {
      socket.onOpen(() => print("SOCKET OPENED!"));
      socket.onError((e) => print("SOCKET ERROR: $e"));
      socket.onClose((c) => print("SOCKET CLOSE: $c"));
      return true;
    }());
  }

  _createChannel(String name, User user) {
    if (name == null ||
        user == null ||
        socket.channels.indexWhere(
                (PhoenixChannel chnl) => chnl.topic == "users:$name") >
            -1) return;

    var userChannel = socket.channel("users:$name");
    userChannel.onError((payload, ref, joinRef) =>
        print("CHANNEL ERROR:\n$ref\n$joinRef\n$payload"));
    userChannel.onClose((Map payload, String ref, String joinRef) {
      print("CHANNEL CLOSE:\n$ref\n$joinRef\n$payload");
    });

    userChannel.on("new_pulse", (Map payload, String _ref, String _joinRef) {
      assert(() {
        print("NEW_PULSE: $payload");
        return true;
      }());

      try {
        Pulse pulse = Pulse.fromJson(payload);
        if (user != null && pulse != null) {
          var machine =
              user.recentMachines?.firstWhere((xp) => xp.name == pulse.machine);

          var totalNew = $(pulse.xps).sumBy((xp) => xp.amount).floor();

          user.totalXp = user.totalXp + totalNew;

          if (machine != null) {
            machine.xp = machine.xp + totalNew;
          }
          pulse?.xps?.forEach((xp) {
            var lang = user.recentLangs
                ?.firstWhere((langXp) => langXp.name == xp.language);

            if (lang != null) {
              lang.xp = lang.xp + xp.amount;
            } else {
              user.recentLangs?.add(Xp(xp.amount, xp.language));
            }
          });

          _userStateController.sink.add(state);
        }
      } catch (e) {
        print(e);
      }
    });
    userChannel.join();
  }

  _refreshChannels(UserState state) async {
    await socket.connect();
    state?.allUsers?.forEach(_createChannel);
  }

  _setUserState(UserState newState) {
    state = newState;
  }

  fetchAllUsers() async {
    if (state?.allUsers?.isNotEmpty ?? false) {
      setDataFetching.add(DataFetching.Loading);

      var userNames = state.allUsers.keys.toList();

      try {
        var response = await _dio.post("/profile-graph",
            data: {"query": queries.profiles(userNames, DateTime.now())});
        if (response.statusCode == 200) {
          var data = response.data["data"];

          if (data != null) {
            userNames.forEach((user) {
              var userMap = data[user];
              if (userMap != null) {
                state.allUsers[user] = User.fromJson(userMap);
              }
            });

            _refreshChannels(state);
            _userStateController.sink.add(state);
            setDataFetching.add(DataFetching.Done);
          } else {
            setDataFetching.add(DataFetching.Error);
            state.errors.clear();
            state.errors.add('Received data was corrupt');
          }
        } else {
          setDataFetching.add(DataFetching.Error);
          state.errors.clear();
          state.errors.add('Server responded with ${response.statusCode}');
          // TODO display errors in UI
        }
      } on DioError catch (e) {
        setDataFetching.add(DataFetching.Error);

        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
        if (e.response != null) {
          print(e.response.data);
          print(e.response.headers);
          print(e.response.request);
        } else {
          // Something happened in setting up or sending
          // the request that triggered an Error
          print(e.message);
        }
      }
    }
  }

  _onSearchUser(String userName) async {
    print("Searching for: $userName");

    _searchResultSubject.add(null);
    _userValidationSubject.add(ValidUser.Loading);

    try {
      Response response = await _dio.get("/api/users/$userName");

      if (response.data == null || response.data["error"] != null) {
        _userValidationSubject.add(ValidUser.Invalid);
      }

      _searchResultSubject.add(response.data);
      _userValidationSubject.add(ValidUser.Valid);
    } catch (e) {
      if (e is DioError &&
          e.type == DioErrorType.RESPONSE &&
          e.response.statusCode == 404) {
        _userValidationSubject.add(ValidUser.Invalid);
      } else {
        _userValidationSubject.add(ValidUser.Error);
      }
    }
  }

  addUser(String newUser) async {
    state.allUsers[newUser] = null;
    _userStateController.add(state);
    _currentUserController.add(newUser);
    await fetchAllUsers();
  }

  removeUser(String username) {
    state.allUsers.remove(username);
    socket.channels
        .firstWhere((channel) => channel.topic == "users:$username")
        ?.leave();
    if (_currentUserController.value == username) {
      if (state.allUsers.isNotEmpty) {
        _currentUserController.add(state.allUsers.keys.first);
      } else {
        _currentUserController.add(null);
      }
    }
    _userStateController.sink.add(state);
  }

  @override
  void dispose() {
    _currentUserController.close();
    _userStateController.close();
    _userValidationSubject.close();
    _dataFetchingSubject.close();
    _searchResultSubject.close();
    _searchUserSubject.close();
  }
}
