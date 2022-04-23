import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/linear_percent_indicator.dart';
import 'package:flutter/material.dart';

class LevelPercentIndicator extends StatefulWidget {
  const LevelPercentIndicator(
      {Key? key,
      required this.width,
      required this.xp,
      required this.name,
      this.recent})
      : super(key: key);

  final double width;
  final int xp;
  final String name;
  final int? recent;

  @override
  _LevelPercentIndicatorState createState() => _LevelPercentIndicatorState();
}

class _LevelPercentIndicatorState extends State<LevelPercentIndicator> {
  @override
  Widget build(BuildContext context) {
    var level = getLevel(widget.xp);
    var previousLevelXp = getXp(level).toDouble();
    var nextLevelXp = getXp(level + 1);
    var thisLevelXpSoFar = widget.xp - previousLevelXp;
    var thisLevelXpTotal = nextLevelXp - previousLevelXp;
    double percent = thisLevelXpSoFar / thisLevelXpTotal;
    String percentText = "${(percent * 100).round()} %";
    double? recentPercent;

    if (widget.recent != null) {
      recentPercent = percent;
      percent = ((thisLevelXpSoFar - (widget.recent ?? 0)) / thisLevelXpTotal)
          .clamp(0.0, 1.0)
          .toDouble();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 50),
      child: Column(
        children: [
          RichText(
            text:
                TextSpan(style: DefaultTextStyle.of(context).style, children: [
              TextSpan(
                  text: widget.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text:
                    " level $level (${formatNumber(widget.xp)} XP) ${widget.recent != null ? '(+${widget.recent})' : ''}",
              ),
            ]),
          ),
          LinearPercentIndicator(
            animation: true,
            width: widget.width,
            lineHeight: 14.0,
            percent: percent,
            recent: recentPercent,
            center: Text(
              percentText,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.black,
              ),
            ),
            leading: Text("$level"),
            trailing: Text("${level + 1}"),
            alignment: MainAxisAlignment.center,
            progressColor: Colors.lightGreen.shade400,
            recentColor: Colors.amber.shade600,
          ),
        ],
      ),
    );
  }
}
