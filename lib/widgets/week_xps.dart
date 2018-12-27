import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/widgets/day_language_xps.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class WeekStatistics extends StatelessWidget {
  const WeekStatistics({
    Key key,
    @required this.userModel,
    @required this.colors,
  }) : super(key: key);

  final UserModel userModel;
  final Map<String, charts.Color> colors;

  @override
  Widget build(BuildContext context) {
    final Random rand = Random();
    // Find all languages
    Map<String, List<DayLanguageXps>> languages = groupBy(
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

    return Column(
      children: [
        DayLanguageXpsWidget(
          userModel: userModel,
          languages: languages,
          colors: colors,
        ),
      ],
    );
  }
}
