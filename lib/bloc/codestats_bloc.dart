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

class UserBloc implements BlocBase {
  UserState state;

  final socket = PhoenixSocket(
      "wss://codestats.net/live_update_socket/websocket?vsn=2.0.0");
  final Dio _dio = Dio(
    Options(
      baseUrl: "https://codestats.net",
    ),
  );

  HydratedSubject<String> _currentUserController =
      HydratedSubject<String>("currentUser", seedValue: "");

  StreamSink<String> get selectUser => _currentUserController.sink;

  Stream<String> get selectedUser => _currentUserController.stream;

  HydratedSubject<UserState> _userStateController;

  Stream<UserState> get users => _userStateController.stream;

  UserBloc() {
    _userStateController = HydratedSubject<UserState>("userState",
        hydrate: (s) {
          try {
            return UserState.fromJson(jsonDecode(s));
          } catch (e) {
            return null;
          }
        },
        persist: (state) => jsonEncode(state.toJson()),
        seedValue: UserState(
          allUsers: {"Schwusch": null, "MasterBait": null},
        ),
        onHydrate: fetchAllUsers);

    _userStateController.stream.listen(_setUserState);
    setupDebugLog(_dio);

    assert(() {
      socket.onMessage((message) => print("SOCKET_MESSAGE: $message"));
      socket.onOpen(() => print("SOCKET OPENED!"));
      socket.onError((e) => print("SOCKET ERROR: $e"));
      socket.onClose((c) => print("SOCKET CLOSE: $c"));
      return true;
    }());
  }

  _refreshChannels(UserState state) async {
    await socket.connect();
    socket.channels.forEach((c) => c.leave());
    socket.channels.clear();
    state?.allUsers?.forEach((name, user) {
      var userChannel = socket.channel("users:$name");
      userChannel.onError((payload, ref, joinRef) => print("CHANNEL ERROR:\n$ref\n$joinRef\n$payload"));
      userChannel.onClose((Map payload, String ref, String joinRef) =>
          print("CHANNEL CLOSE:\n$ref\n$joinRef\n$payload"));

      userChannel.on("new_pulse", (Map payload, String _ref, String _joinRef) {
        assert(() {
          print("NEW_PULSE:\n$payload");
          return true;
        }());

        try {
          Pulse pulse = Pulse.fromJson(payload);
          if (user != null && pulse != null) {
            var machine = user?.recentMachines
                ?.firstWhere((xp) => xp.name == pulse.machine);
            if (machine != null) {
              machine.xp =
                  machine.xp + $(pulse.xps).sumBy((xp) => xp.amount).floor();
            }
            pulse?.xps?.forEach((xp) {
              var lang = user?.recentLangs
                  ?.firstWhere((langXp) => langXp.name == xp.language);
              if (lang != null) {
                lang.xp = lang.xp + xp.amount;
              } else {
                user?.recentLangs?.add(Xp(xp.amount, xp.language));
              }
            });
            _userStateController.sink.add(state);
          }
        } catch (e) {
          print(e);
        }
      });
      userChannel.join();
    });
  }

  _setUserState(UserState newState) {
    state = newState;
  }

  fetchAllUsers() async {
    if (state?.allUsers?.isNotEmpty ?? false) {
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
          }
        } else {
          state.errors.clear();
          state.errors.add('Server responded with ${response.statusCode}');
        }
      } on DioError catch (e) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
        if (e.response != null) {
          print(e.response.data);
          print(e.response.headers);
          print(e.response.request);
        } else {
          // Something happened in setting up or sending the request that triggered an Error
          print(e.message);
        }
      }
    }
  }

  @override
  void dispose() {
    _currentUserController.close();
    _userStateController.close();
  }
}
