import 'package:charts_flutter/flutter.dart' as charts;
import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/widgets/day_language_xps.dart';
import 'package:flutter/material.dart';

class WeekStatistics extends StatelessWidget {
  const WeekStatistics({
    Key key,
    @required this.userModel,
    @required this.languages,
    @required this.colors,
  }) : super(key: key);

  final UserModel userModel;
  final Map<String, List<DayLanguageXps>> languages;
  final Map<String, charts.Color> colors;

  @override
  Widget build(BuildContext context) {
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
