import 'dart:math';

import 'package:codestats_flutter/usermodel.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:superpower/superpower.dart';

int getLevel(int xp) {
  return (0.025 * sqrt(xp)).floor();
}

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

    languages.forEach((key, _) {
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

    var recentXp = $(userModel.recentLangs).sumBy((elem) => elem.xp).floor();
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            [
              SliverAppBar(
                forceElevated: innerBoxIsScrolled,
                expandedHeight: 100,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        username,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "Level ${getLevel(userModel.totalXp)} (${userModel.totalXp} XP) ${recentXp > 0 ? "(+$recentXp)" : ""}",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: groupBy(userModel.dayLanguageXps,
                                      (DayLanguageXps elem) => elem.date)
                                  .keys
                                  .length *
                              2 *
                              50.0,
                          child: charts.BarChart(
                            languages.values
                                .map((dlx) =>
                                    charts.Series<DayLanguageXps, String>(
                                      id: dlx.first.language,
                                      domainFn: (DayLanguageXps elem, _) =>
                                          elem.date,
                                      measureFn: (DayLanguageXps elem, _) =>
                                          elem.xp,
                                      data: dlx,
                                      colorFn: (elem, _) =>
                                          colors[elem.language],
                                    ))
                                .toList(),
                            animate: true,
                            barGroupingType: charts.BarGroupingType.stacked,
                            vertical: false,
                            behaviors: [
                              charts.SeriesLegend(
                                position: charts.BehaviorPosition.top,
                                outsideJustification:
                                    charts.OutsideJustification.endDrawArea,
                                horizontalFirst: false,
                                desiredMaxRows:
                                    (languages.keys.length / 2).floor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
