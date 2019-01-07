import 'dart:async';
import 'dart:convert';
import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/models/pulse/pulse.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:flutter/material.dart';
import 'package:hydrated/hydrated.dart';
import 'package:dio/dio.dart';
import 'package:codestats_flutter/queries.dart' as queries;
import 'package:codestats_flutter/utils.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:superpower/superpower.dart';
import 'package:rxdart/subjects.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:random_color/random_color.dart';

enum ValidUser { Unknown, Loading, Valid, Invalid, Error }

enum DataFetching { Done, Loading, Error }

class UserBloc implements BlocBase {
  static const baseUrl = "https://codestats.net";
  static const wsBaseUrl = "wss://codestats.net/live_update_socket/websocket";
  final _possibleColors = Colors.primaries
      .map((c) => charts.ColorUtil.fromDartColor(c))
      .toList()
        ..shuffle();
  final Map<String, charts.Color> _languageColors = {};

  RandomColor _randomColor = RandomColor();

  final socket = PhoenixSocket(
    wsBaseUrl,
    socketOptions: PhoenixSocketOptions(
      params: {"vsn": "2.0.0"},
    ),
  );

  final _dio = Dio(
    Options(
      baseUrl: baseUrl,
    ),
  );

  HydratedSubject<String> _currentUserController =
      HydratedSubject<String>("currentUser", seedValue: "");

  final HydratedSubject<int> recentLength = HydratedSubject<int>("recentLength", seedValue: 7);

  StreamSink<String> get selectUser => _currentUserController.sink;

  Stream<String> get selectedUser => _currentUserController.stream;

  HydratedSubject<UserState> userStateController;

  PublishSubject<ValidUser> _userValidationSubject = PublishSubject();

  Stream<ValidUser> get userValidation =>
      _userValidationSubject.stream.startWith(ValidUser.Unknown);

  StreamSink<ValidUser> get setUserValidation => _userValidationSubject.sink;

  PublishSubject<DataFetching> _dataFetchingSubject = PublishSubject();

  Stream<DataFetching> get dataFetching =>
      _dataFetchingSubject.stream.startWith(DataFetching.Done);

  StreamSink<DataFetching> get setDataFetching => _dataFetchingSubject.sink;

  PublishSubject<Map<String, dynamic>> _searchResultSubject = PublishSubject();

  Stream<Map<String, dynamic>> get searchResult => _searchResultSubject.stream;

  PublishSubject<String> _searchUserSubject = PublishSubject();

  StreamSink<String> get searchUser => _searchUserSubject;

  BehaviorSubject<int> chosenTab = BehaviorSubject(seedValue: 0);

  final PublishSubject<String> errors = PublishSubject<String>();

  UserBloc() {
    userStateController = HydratedSubject<UserState>("userState",
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

    _searchUserSubject
        .distinct()
        .debounce(Duration(milliseconds: 750))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .listen(this._onSearchUser);
    setupDebugLog(_dio);

    socket.onError((e) {
      _debugPrint("SOCKET_ERROR: $e");
      fetchAllUsers();
    });
    socket.onClose((c) {
      _debugPrint("SOCKET_CLOSE: $c");
      fetchAllUsers();
    });
  }

  charts.Color languageColor(String language) {
    if (_languageColors[language] == null) {
      if (_possibleColors.isNotEmpty) {
        _languageColors[language] = _possibleColors.removeLast();
      } else {
        _languageColors[language] =
            charts.ColorUtil.fromDartColor(_randomColor.randomColor());
      }
    }
    return _languageColors[language];
  }

  _createChannel(String name, User _) {
    if (name == null ||
        socket.channels.indexWhere(
                (PhoenixChannel chnl) => chnl.topic == "users:$name") >
            -1) return;

    var userChannel = socket.channel("users:$name");
    userChannel.onError((payload, ref, joinRef) =>
        _debugPrint("CHANNEL ERROR:\n$ref\n$joinRef\n$payload"));
    userChannel.onClose((Map payload, String ref, String joinRef) {
      _debugPrint("CHANNEL CLOSE:\n$ref\n$joinRef\n$payload");
    });

    userChannel.on("new_pulse", (Map payload, String _ref, String _joinRef) {
      _debugPrint("NEW_PULSE: $payload");
      var state = userStateController.value;
      var user = state.allUsers[name];
      try {
        Pulse pulse = Pulse.fromJson(payload);
        if (user != null && pulse != null) {
          var recentMachine =
              user.recentMachines?.firstWhere((xp) => xp.name == pulse.machine);
          var machine =
              user.totalMachines?.firstWhere((xp) => xp.name == pulse.machine);

          var totalNew = $(pulse.xps).sumBy((xp) => xp.amount).floor();

          user.totalXp = user.totalXp + totalNew;

          if (recentMachine != null) {
            recentMachine.xp = recentMachine.xp + totalNew;
          }

          if (machine != null) {
            machine.xp = machine.xp + totalNew;
          }

          pulse?.xps?.forEach((xp) {
            var recentLang = user.recentLangs
                ?.firstWhere((langXp) => langXp.name == xp.language);
            var lang = user.totalLangs
                ?.firstWhere((langXp) => langXp.name == xp.language);

            if (recentLang != null) {
              recentLang.xp = recentLang.xp + xp.amount;
            } else {
              user.recentLangs?.add(Xp(xp.amount, xp.language));
            }

            if (lang != null) {
              lang.xp = lang.xp + xp.amount;
            } else {
              user.totalLangs?.add(Xp(xp.amount, xp.language));
            }
          });

          userStateController.add(state);
        }
      } catch (e) {
        _debugPrint("PULSE_ERROR: $e");
      }
    });
    userChannel.join();
  }

  _refreshChannels(UserState state) async {
    await socket.connect();
    state?.allUsers?.forEach(_createChannel);
  }

  fetchAllUsers() async {
    var state = userStateController.value;

    if (state?.allUsers?.isNotEmpty ?? false) {
      setDataFetching.add(DataFetching.Loading);

      var userNames = state.allUsers.keys.toList();

      try {
        var response = await _dio.post("/profile-graph",
            data: {"query": queries.profiles(userNames, DateTime.now(), recentLength.value)});
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
            userStateController.add(state);
            setDataFetching.add(DataFetching.Done);
          } else {
            setDataFetching.add(DataFetching.Error);
            errors.add('No data was received from the server');
          }

          List graphQlErrors = response.data['errors'];
          graphQlErrors?.forEach((e) {
            errors.add('${e['path']?.first ?? ""} - ${e['message']}');
          });
        } else {
          setDataFetching.add(DataFetching.Error);
          errors.add('Server responded with ${response.statusCode}');
        }
      } on DioError catch (e) {
        setDataFetching.add(DataFetching.Error);
        errors.add(e.toString());
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
    var state = userStateController.value;
    state.allUsers[newUser] = null;
    userStateController.add(state);
    _currentUserController.add(newUser);
    await fetchAllUsers();
  }

  removeUser(String username) {
    var state = userStateController.value;
    state.allUsers.remove(username);
    socket.channels
        .firstWhere((channel) => channel.topic == "users:$username",
            orElse: () => null)
        ?.leave();
    if (_currentUserController.value == username || state.allUsers.isEmpty) {
      if (state.allUsers.isNotEmpty) {
        selectUser.add(state.allUsers.keys.first);
      } else {
        selectUser.add("");
      }
    }

    userStateController.sink.add(state);
  }

  _debugPrint(dynamic d) {
    assert(() {
      print("$d");
      return true;
    }());
  }

  @override
  void dispose() {
    _currentUserController.close();
    userStateController.close();
    _userValidationSubject.close();
    _dataFetchingSubject.close();
    _searchResultSubject.close();
    _searchUserSubject.close();
    chosenTab.close();
    errors.close();
    recentLength.close();
  }
}
