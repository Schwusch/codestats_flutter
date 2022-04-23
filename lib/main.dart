import 'package:codestats_flutter/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'bloc/codestats_bloc.dart';
import 'pages/add_user_page.dart';
import 'pages/tab_navigator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Provider<UserBloc>(
    create: (context) => UserBloc(),
    dispose: (context, bloc) => bloc.dispose(),
    child: const CodeStatsApp(),
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class CodeStatsApp extends StatefulWidget {
  static const platform = MethodChannel('app.channel.shared.data');

  const CodeStatsApp({Key? key}) : super(key: key);

  @override
  CodeStatsAppState createState() => CodeStatsAppState();
}

class CodeStatsAppState extends State<CodeStatsApp>
    with WidgetsBindingObserver {
  getIntentLastPathSegment(BuildContext context,
      {bool fetchAll = false}) async {
    String? user;
    try {
      user =
          await CodeStatsApp.platform.invokeMethod("getIntentLastPathSegment");
    } catch (e) {
      log(e);
    }

    log("getIntentLastPathSegment: $user");

    final _bloc = context.read<UserBloc>();
    if (user != null && user != "users") {
      if (_bloc.currentUserControllerIsHydrated) {
        _bloc.addUser(user);
      } else {
        _bloc.currentUserControllerTasksOnHydrate.add(() {
          _bloc.addUser(user!);
        });
      }
    } else if (fetchAll) {
      if (_bloc.currentUserControllerIsHydrated) {
        _bloc.fetchAllUsers();
      } else {
        _bloc.currentUserControllerTasksOnHydrate.add(() {
          _bloc.fetchAllUsers();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getIntentLastPathSegment(context, fetchAll: true);
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      getIntentLastPathSegment(context, fetchAll: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: Typography().white.apply(
            bodyColor: Colors.blueGrey[600],
            displayColor: Colors.blueGrey[600]),
        primarySwatch: Colors.blueGrey,
      ),
      title: 'Code::Stats',
      initialRoute: "home",
      routes: {
        "home": (_) => const TabNavigator(),
        "addUser": (_) => const AddUserPage(),
      },
    );
  }
}
