import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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
          return TabNavigator(
            colors: colors,
            users: snapshot.data != null ? snapshot.data[0].allUsers : null,
            currentUser: snapshot.data != null ? snapshot.data[1] : null,
          );
        });
  }
}
