import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/add_user_page.dart';
import 'package:codestats_flutter/widgets/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(CodeStatsApp()));
}

class CodeStatsApp extends StatefulWidget{
  static const platform = MethodChannel('app.channel.shared.data');

  @override
  CodeStatsAppState createState() => CodeStatsAppState();
}

class CodeStatsAppState extends State<CodeStatsApp> with WidgetsBindingObserver {
  final UserBloc _bloc = UserBloc()..fetchAllUsers();

  getIntentLastPathSegment() async {
    String user = await CodeStatsApp.platform.invokeMethod("getIntentLastPathSegment");
    print("getIntentLastPathSegment: $user");
    if(user != null && user != "users") {
      await _bloc.userStateController.hydrateSubject();
      _bloc.addUser(user);
    } else {
      _bloc.userStateController.hydrateSubject();
    }
  }

  @override
  void initState() {
    super.initState();
    getIntentLastPathSegment();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed) {
      getIntentLastPathSegment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
      bloc: _bloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Code::Stats',
        theme: ThemeData(
          textTheme: Typography(platform: TargetPlatform.android).white.apply(
              bodyColor: Colors.blueGrey[600],
              displayColor: Colors.blueGrey[600]),
          primarySwatch: Colors.blueGrey,
        ),
        initialRoute: "/",
        routes: {
          "/": (_) => TabNavigator(),
          "/addUser": (_) => AddUserPage(),
        },
      ),
    );
  }
}
