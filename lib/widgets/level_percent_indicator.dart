import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/linear_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LevelPercentIndicator extends StatelessWidget {
  const LevelPercentIndicator(
      {Key key, @required this.width, @required this.xp, @required this.name, this.recent})
      : super(key: key);

  final double width;
  final int xp;
  final String name;
  final int recent;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    var level = getLevel(xp);
    var previousLevelXp = getXp(level).toDouble();
    var nextLevelXp = getXp(level + 1);
    var thisLevelXpSoFar = xp - previousLevelXp;
    var thisLevelXpTotal = nextLevelXp - previousLevelXp;
    double percent = thisLevelXpSoFar / thisLevelXpTotal;
    String percentText = "${(percent * 100).round()} %";
    double recentPercent;

    if(recent != null) {
      recentPercent = percent;
      percent = ((thisLevelXpSoFar - recent) / thisLevelXpTotal).clamp(0.0, 1.0).toDouble();
    }

    return Column(
      children: [
        RichText(
          text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
            TextSpan(text: name, style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: " level $level (${formatter.format(xp)} XP) ${recent != null ? '(+$recent)' : ''}",
            ),
          ]),
        ),
        LinearPercentIndicator(
          animation: true,
          width: width,
          lineHeight: 14.0,
          percent: percent,
          recent: recentPercent,
          center: Text(
            percentText,
            style: TextStyle(fontSize: 12.0, color: Colors.black,),
          ),
          leading: Text("$level"),
          trailing: Text("${level + 1}"),
          alignment: MainAxisAlignment.center,
          progressColor: Colors.green,
          recentColor: Colors.amber,
        ),
      ],
    );
  }
}
