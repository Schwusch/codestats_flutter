import 'dart:math';

import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/widgets/language_levels.dart';
import 'package:codestats_flutter/widgets/profile_page.dart';
import 'package:codestats_flutter/widgets/week_xps.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flip_box_bar/flip_box_bar.dart';

class TabNavigator extends StatefulWidget {
  final UserModel userModel;
  final String username;
  final Map<String, charts.Color> colors;
  final Random rand = Random();

  TabNavigator({
    @required this.userModel,
    @required this.username,
    @required this.colors,
  });

  @override
  TabNavigatorState createState() {
    return new TabNavigatorState();
  }
}

class TabNavigatorState extends State<TabNavigator> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Find all languages
    var languages = groupBy(widget.userModel.dayLanguageXps,
        (DayLanguageXps element) => element.language);

    languages.forEach((key, list) {
      // Check if language is already given a color
      // Languages does not have to change color every update
      if (widget.colors[key] == null) {
        // Randomize a color
        var color = charts.ColorUtil.fromDartColor(
            Colors.primaries[widget.rand.nextInt(Colors.primaries.length)]);
        // Find a unique color
        while (widget.colors.values.contains(color)) {
          color = charts.ColorUtil.fromDartColor(
              Colors.primaries[widget.rand.nextInt(Colors.primaries.length)]);
        }

        widget.colors[key] = color;
      }
    });
    Widget body;
    switch (tabIndex) {
      case 0:
        body = ProfilePage(
          userModel: widget.userModel,
        );
        break;
      case 1:
        body = WeekStatistics(
          userModel: widget.userModel,
          colors: widget.colors,
          languages: languages,
        );
        break;
      case 2:
        body = LanguageLevelPage(
          userModel: widget.userModel,
        );
        break;
      case 3:
        // TODO Year view
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: body,
      bottomNavigationBar: FlipBoxBar(
        animationDuration: Duration(milliseconds: 500),
        items: [
          FlipBarItem(
            icon: Icon(Icons.person),
            text: Text("Profile"),
            frontColor: Colors.amber[700],
            backColor: Colors.amber[300],
          ),
          FlipBarItem(
              icon: Icon(Icons.timer),
              text: Text("Week"),
              frontColor: Colors.green[800],
              backColor: Colors.green[300]),
          FlipBarItem(
              icon: Icon(Icons.translate),
              text: Text("Languages"),
              frontColor: Colors.purple[700],
              backColor: Colors.purple[300]),
          FlipBarItem(
            icon: Icon(Icons.calendar_today),
            text: Text("Year view"),
            frontColor: Colors.cyan.shade700,
            backColor: Colors.cyan.shade200,
          ),

        ],
        onIndexChanged: (newIndex) => setState(() {
          tabIndex = newIndex;
        }),
      ),
    );
  }
}
