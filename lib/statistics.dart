import 'dart:math';

import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/widgets/profile_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flip_box_bar/flip_box_bar.dart';

class StatisticsWidget extends StatelessWidget {
  final UserModel userModel;
  final String username;
  final Random rand = Random();

  // Assign avery language their own color
  final Map<String, charts.Color> colors;

  StatisticsWidget({
    @required this.userModel,
    @required this.username,
    @required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Find all languages
    var languages = groupBy(
        userModel.dayLanguageXps, (DayLanguageXps element) => element.language);

    languages.forEach((key, list) {
      // Check if language is already given a color
      // Languages does not have to change color every update
      if (colors[key] == null) {
        // Randomize a color
        var color = charts.ColorUtil.fromDartColor(
            Colors.primaries[rand.nextInt(Colors.primaries.length)]);
        // Find a unique color
        while (colors.values.contains(color)) {
          color = charts.ColorUtil.fromDartColor(
              Colors.primaries[rand.nextInt(Colors.primaries.length)]);
        }

        colors[key] = color;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: ProfilePage(userModel: userModel),
      bottomNavigationBar: FlipBoxBar(
        items: [
          FlipBarItem(
              icon: Icon(Icons.timer),
              text: Text("Week"),
              frontColor: Colors.green[800],
              backColor: Colors.green[400]),
          FlipBarItem(
              icon: Icon(Icons.translate),
              text: Text("Languages"),
              frontColor: Colors.purple[700],
              backColor: Colors.purple[300]),
          FlipBarItem(
            icon: Icon(Icons.person),
            text: Text("Profile"),
            frontColor: Colors.amber[700],
            backColor: Colors.amber[300],
          ),
        ],
        onIndexChanged: (newIndex) => print(newIndex),
      ),
    );
  }
}
