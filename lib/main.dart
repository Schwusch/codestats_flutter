import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:codestats_flutter/bloc/events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/delegates.dart';
import 'package:codestats_flutter/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:codestats_flutter/queries.dart' as queries;
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  BlocSupervisor().delegate = LogTransitionDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UserBloc _bloc = UserBloc();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Client> client = ValueNotifier(
      Client(
        endPoint: "https://codestats.net/profile-graph",
        cache: InMemoryCache(),
      ),
    );

    return GraphqlProvider(
      client: client,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Code::Stats',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: BlocProvider<UserBloc>(
          bloc: _bloc,
          child: HomePage(),
        ),
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
    final now = DateTime.now();

    return BlocBuilder<UserEvent, UserState>(
      bloc: _userbloc,
      builder: (context, UserState state) => Query(
          queries.profiles(state.allUsers, now.subtract(Duration(hours: 12))),
          pollInterval: 30,
          builder: ({
            bool loading,
            Map data,
            Exception error,
          }) =>
              TabNavigator(
                colors: colors,
                error: error,
                data: data,
                loading: loading,
              )),
    );
  }
}
