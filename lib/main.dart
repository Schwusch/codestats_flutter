import 'dart:math';

import 'package:codestats_flutter/statistics.dart';
import 'package:codestats_flutter/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:codestats_flutter/queries.dart' as queries;
import 'package:charts_flutter/flutter.dart' as charts;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of y our application.
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
        title: 'Code::Stats',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "Schwusch";
  Random rand = Random();
  int updates = 0;

  // Assign avery language their own color
  Map<String, charts.Color> colors = {};

  @override
  Widget build(BuildContext context) {
    return Query(
      queries.profile(username, DateTime.now()),
      pollInterval: 30,
      variables: {"username": username},
      builder: ({
        bool loading,
        Map data,
        Exception error,
      }) {
        if (error != null) {
          return Center(child: Text(error.toString()));
        }

        if (loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        updates++;
        print("Updating Statistics $updates...");

        return StatisticsWidget(
          userModel: UserModel.fromJson(data[username]),
          username: username,
          colors: colors,
        );
      },
    );
  }
}
