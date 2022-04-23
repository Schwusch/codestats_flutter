import 'dart:async' show Stream, StreamSink;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:codestats_flutter/utils.dart';
import 'package:hydrated/hydrated.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/models/pulse/pulse.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:dio/dio.dart'
    show Dio, DioError, DioErrorType, LogInterceptor, Response;
import 'package:codestats_flutter/queries.dart' as queries;
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:charts_flutter/flutter.dart' as charts show Color, ColorUtil;
import 'package:random_color/random_color.dart' show RandomColor;

import 'bloc_provider.dart';

enum ValidUser { Unknown, Loading, Valid, Invalid, Error }

enum DataFetching { Done, Loading, Error }

enum TabSource { BottomNavigation, Swipe }

class TabEvent {
  final int tab;
  final TabSource source;

  TabEvent(this.tab, this.source);
}

class UserWrap {
  final String? name;
  final User? data;

  UserWrap({this.name, this.data});
}

class OnlyOnceData<T> {
  final T? _value;
  bool used = false;

  T? get value {
    if (used) return null;

    used = true;
    return _value;
  }

  OnlyOnceData(this._value);
}

class UserBloc implements BlocBase {
  static const baseUrl = "https://codestats.net";
  static const wsBaseUrl = "wss://codestats.net/live_update_socket/websocket";
  final _possibleColors = Colors.primaries
      .map((c) => charts.ColorUtil.fromDartColor(c))
      .toList()
    ..shuffle();
  final Map<String, charts.Color> _languageColors = {};

  final RandomColor _randomColor = RandomColor();

  final socket = PhoenixSocket(
    wsBaseUrl,
    socketOptions: PhoenixSocketOptions(
      params: {"vsn": "2.0.0"},
    ),
  );

  final _dio = Dio()..options.baseUrl = baseUrl;

  late HydratedSubject<String> currentUserController;

  final currentUserControllerTasksOnHydrate = <void Function()>[];

  bool currentUserControllerIsHydrated = false;

  final HydratedSubject<int> recentLength =
      HydratedSubject<int>("recentLength", seedValue: 7);

  StreamSink<String> get selectUser => currentUserController;

  Stream<String> get selectedUser => currentUserController;

  late HydratedSubject<UserState> userStateController;

  final PublishSubject<ValidUser> _userValidationSubject = PublishSubject();

  Stream<ValidUser> get userValidation =>
      _userValidationSubject.stream.startWith(ValidUser.Unknown);

  StreamSink<ValidUser> get setUserValidation => _userValidationSubject.sink;

  final BehaviorSubject<DataFetching> _dataFetchingSubject = BehaviorSubject();

  Stream<DataFetching> get dataFetching =>
      _dataFetchingSubject.stream.startWith(DataFetching.Done);

  StreamSink<DataFetching> get setDataFetching => _dataFetchingSubject.sink;

  final PublishSubject<Map<String, dynamic>?> _searchResultSubject =
      PublishSubject();

  Stream<Map<String, dynamic>?> get searchResult => _searchResultSubject.stream;

  final PublishSubject<String> _searchUserSubject = PublishSubject();

  StreamSink<String> get searchUser => _searchUserSubject;

  final PublishSubject<String> errors = PublishSubject<String>();

  final PublishSubject<OnlyOnceData<String>> pulses = PublishSubject();

  Stream<UserWrap> get currentUser =>
      Rx.combineLatest2(userStateController, currentUserController,
          (UserState? state, String user) {
        final users = state?.allUsers ?? <String, User>{};
        return UserWrap(name: user, data: users[user]);
      });

  UserBloc() {
    currentUserController = HydratedSubject<String>(
      "currentUser",
      seedValue: "",
      onHydrate: () {
        currentUserControllerIsHydrated = true;
        for (var f in currentUserControllerTasksOnHydrate) {
          f();
        }
        currentUserControllerTasksOnHydrate.clear();
      },
    );
    userStateController = HydratedSubject<UserState>(
      "userState",
      hydrate: decodeUserState,
      seedValue: UserState.empty(),
      persist: encodeUserStore,
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true,
        requestBody: true,
      ));
    }

    _searchUserSubject
        .distinct()
        .debounce((_) => TimerStream(true, const Duration(milliseconds: 750)))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .listen(_onSearchUser);

    socket.onError((e) {
      log("SOCKET_ERROR: $e");
      fetchAllUsers();
    });
    socket.onClose((c) {
      log("SOCKET_CLOSE: $c");
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
    return _languageColors[language]!;
  }

  void _createChannel(String? name, User? _) {
    if (name == null ||
        socket.channels.indexWhere(
                (PhoenixChannel chnl) => chnl.topic == "users:$name") >
            -1) return;

    var userChannel = socket.channel("users:$name");
    userChannel.onError((payload, ref, joinRef) =>
        log("CHANNEL ERROR:\n$ref\n$joinRef\n$payload"));
    userChannel.onClose((Map? payload, String? ref, String? joinRef) {
      log("CHANNEL CLOSE:\n$ref\n$joinRef\n$payload");
    });

    userChannel.on("new_pulse", (Map? payload, String? _ref, String? _joinRef) {
      log("NEW_PULSE: $payload");
      if (payload == null || payload is! Map<String, dynamic>) return;

      var state = userStateController.value;
      var user = state.allUsers[name];

      try {
        final pulse = payload.let<Pulse>(Pulse.fromJson);
        if (user != null) {
          if (currentUserController.value == name) {
            pulses.add(OnlyOnceData(pulse.xps.join("\n")));
          }

          var recentMachine = user.recentMachines
              .firstWhereOrNull((xp) => xp.name == pulse.machine);
          var machine = user.totalMachines
              .firstWhereOrNull((xp) => xp.name == pulse.machine);

          var totalNew =
              pulse.xps.fold<int>(0, (total, xp) => total + xp.amount);

          user.totalXp = user.totalXp + totalNew;

          if (recentMachine != null) {
            recentMachine.xp += totalNew;
          }

          if (machine != null) {
            machine.xp += totalNew;
          }

          for (var xp in pulse.xps) {
            var recentLang = user.recentLangs
                .firstWhereOrNull((langXp) => langXp.name == xp.language);
            var lang = user.totalLangs
                .firstWhereOrNull((langXp) => langXp.name == xp.language);

            if (recentLang != null) {
              recentLang.xp = recentLang.xp + xp.amount;
            } else {
              user.recentLangs.add(Xp(xp.amount, xp.language));
            }

            if (lang != null) {
              lang.xp = lang.xp + xp.amount;
            } else {
              user.totalLangs.add(Xp(xp.amount, xp.language));
            }
          }

          userStateController.add(state);
        }
      } catch (e) {
        log("PULSE_ERROR: $e");
      }
    });
    userChannel.join();
  }

  void refreshChannels(UserState? state) async {
    await socket.connect();
    state?.allUsers.forEach(_createChannel);
  }

  Future<void> fetchAllUsers() async {
    var state = userStateController.value;

    if (state.allUsers.isNotEmpty) {
      setDataFetching.add(DataFetching.Loading);

      var userNames = state.allUsers.keys.toList();

      try {
        final query =
            queries.profiles(userNames, DateTime.now(), recentLength.value);
        log(query);
        var response = await _dio.post("/profile-graph", data: {
          "query": query,
        });
        if (response.statusCode == 200) {
          var data = response.data["data"];

          if (data != null) {
            state.allUsers =
                await compute(decodeUsers, data as Map<String, dynamic>);

            refreshChannels(state);
            userStateController.add(state);
            setDataFetching.add(DataFetching.Done);
          } else {
            setDataFetching.add(DataFetching.Error);
            errors.add('No data was received from the server');
          }

          List? graphQlErrors = response.data['errors'];
          graphQlErrors?.forEach((e) {
            errors.add('${e['path']?.first ?? ""} - ${e['message']}');
          });
        } else {
          setDataFetching.add(DataFetching.Error);
          errors.add('Server responded with ${response.statusCode}');
        }
      } catch (e) {
        setDataFetching.add(DataFetching.Error);
        log(e);
      }
    }
  }

  void _onSearchUser(String userName) async {
    log("Searching for: $userName");

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
          e.type == DioErrorType.response &&
          e.response?.statusCode == 404) {
        _userValidationSubject.add(ValidUser.Invalid);
      } else {
        _userValidationSubject.add(ValidUser.Error);
      }
    }
  }

  void addUser(String newUser) async {
    var state = userStateController.value;

    state.allUsers[newUser] = null;
    userStateController.add(state);
    await fetchAllUsers();

    currentUserController.add(newUser);
  }

  void selectNextUser() {
    var state = userStateController.value;
    if (state.allUsers.isNotEmpty) {
      selectUser.add(state.allUsers.keys.first);
    } else if (currentUserController.value.isNotEmpty) {
      selectUser.add("");
    }
  }

  void removeUser(String username) {
    var state = userStateController.value;
    state.allUsers.remove(username);
    socket.channels
        .firstWhereOrNull((channel) => channel.topic == "users:$username")
        ?.leave();
    selectNextUser();
    userStateController.sink.add(state);
  }

  @override
  void dispose() {
    currentUserController.close();
    userStateController.close();
    _userValidationSubject.close();
    _dataFetchingSubject.close();
    _searchResultSubject.close();
    _searchUserSubject.close();
    errors.close();
    pulses.close();
    recentLength.close();
  }
}

String encodeUserStore(UserState state) {
  return jsonEncode(state.toJson());
}

UserState decodeUserState(String data) {
  try {
    return UserState.fromJson(jsonDecode(data));
  } catch (e) {
    log("Unable to decode UserState");
    return UserState.empty();
  }
}

Map<String, User> decodeUsers(Map<String, dynamic> data) =>
    data.map((str, dyn) => MapEntry(str, User.fromJson(dyn)));
