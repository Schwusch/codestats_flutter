import 'dart:math';

import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  final UserBloc _bloc = UserBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code::Stats',
      theme: ThemeData(
        textTheme: Typography(platform: TargetPlatform.android)
            .white
            .apply(bodyColor: Colors.blueGrey[600]),
        primarySwatch: Colors.blueGrey,
      ),
      home: BlocProvider<UserBloc>(
        bloc: _bloc,
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Random rand = Random();

  // Assign avery language their own color
  Map<String, charts.Color> colors = {};

  @override
  Widget build(BuildContext context) {
    final UserBloc _userbloc = BlocProvider.of(context);

    return StreamBuilder(
        stream: CombineLatestStream(
            [_userbloc.users, _userbloc.selectedUser], (values) => values),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return TabNavigator(
              colors: colors,
              users: snapshot.data[0].allUsers,
              currentUser: snapshot.data[1],
            );
          }

          return Scaffold(
            body: Center(
              child: Text("Something is wrong"),
            ),
          );
        });
  }
}
