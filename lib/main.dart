import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/add_user_page.dart';
import 'package:codestats_flutter/widgets/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_midi/flutter_midi.dart';

void main() {
  runApp(CodeStatsApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class CodeStatsApp extends StatefulWidget {
  static const platform = MethodChannel('app.channel.shared.data');

  @override
  CodeStatsAppState createState() => CodeStatsAppState();
}

class CodeStatsAppState extends State<CodeStatsApp>
    with WidgetsBindingObserver {
  final UserBloc _bloc = UserBloc();

  getIntentLastPathSegment({bool fetchAll = false}) async {
    String user;
    try {
      user =
          await CodeStatsApp.platform.invokeMethod("getIntentLastPathSegment");

    } catch (e) {}
    print("getIntentLastPathSegment: $user");

    var addUser = () {
      _bloc.addUser(user);
    };

    if (user != null && user != "users") {
      if (_bloc.currentUserController.isHydrated) {
        addUser();
      } else {
        _bloc.currentUserController.onHydrate = addUser;
      }
    } else if(fetchAll) {
      if (_bloc.currentUserController.isHydrated) {
      _bloc.fetchAllUsers();
      } else {
        _bloc.currentUserController.onHydrate = () {
          _bloc.fetchAllUsers();
        };
      }
    }
  }

  void loadMidi(String asset) async {
    print("Loading File...");
    //FlutterMidi.unmute();
    ByteData _byte = await rootBundle.load(asset);
    //FlutterMidi.prepare(sf2: _byte, name: asset.replaceAll("midi/", ""));
  }

  @override
  void initState() {
    super.initState();
    loadMidi("midi/zelda.sf2");
    getIntentLastPathSegment(fetchAll: true);
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
    if (state == AppLifecycleState.resumed) {
      getIntentLastPathSegment(fetchAll: true);
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
        initialRoute: "home",
        routes: {
          "home": (_) => TabNavigator(bloc: _bloc,),
          "addUser": (_) => AddUserPage(),
        },
      ),
    );
  }
}
