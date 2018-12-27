import 'dart:math';

import 'package:codestats_flutter/tab_navigator.dart';
import 'package:codestats_flutter/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:codestats_flutter/queries.dart' as queries;
import 'package:charts_flutter/flutter.dart' as charts;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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

  // Assign avery language their own color
  Map<String, charts.Color> colors = {};

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    return Query(
      queries.profile(username, now.subtract(Duration(hours: 12))),
      pollInterval: 30,
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

        return TabNavigator(
          userModel: UserModel.fromJson(data[username]),
          username: username,
          colors: colors,
        );
      },
    );
  }
}
