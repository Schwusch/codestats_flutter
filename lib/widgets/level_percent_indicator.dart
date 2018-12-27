import 'package:codestats_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LevelPercentIndicator extends StatelessWidget {
  const LevelPercentIndicator(
      {Key key, @required this.width, @required this.xp, @required this.name})
      : super(key: key);

  final double width;
  final int xp;
  final String name;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    var level = getLevel(xp);
    var previousLevelXp = getXp(level).toDouble();
    var nextLevelXp = getXp(level + 1);
    var thisLevelXpSoFar = xp - previousLevelXp;
    var thisLevelXpTotal = nextLevelXp - previousLevelXp;
    double percent = thisLevelXpSoFar / thisLevelXpTotal;
    String percentText = "${(percent * 100).floor()} %";

    return Column(
      children: [
        RichText(
          text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
            TextSpan(text: name, style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: " level $level (${formatter.format(xp)} XP)",
            ),
          ]),
        ),
        LinearPercentIndicator(
          width: width,
          lineHeight: 14.0,
          percent: percent,
          center: Text(
            percentText,
            style: new TextStyle(fontSize: 12.0),
          ),
          leading: Text("$level"),
          trailing: Text("${level + 1}"),
          alignment: MainAxisAlignment.center,
          progressColor: Colors.green,
        ),
      ],
    );
  }
}
