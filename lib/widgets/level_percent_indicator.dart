import 'package:codestats_flutter/passthrough_simulation.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/explosion.dart';
import 'package:codestats_flutter/widgets/linear_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LevelPercentIndicator extends StatefulWidget {
  const LevelPercentIndicator(
      {Key key,
      @required this.width,
      @required this.xp,
      @required this.name,
      this.recent})
      : super(key: key);

  final double width;
  final int xp;
  final String name;
  final int recent;

  @override
  _LevelPercentIndicatorState createState() => _LevelPercentIndicatorState();
}

class _LevelPercentIndicatorState extends State<LevelPercentIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController ctrl;

  @override
  void initState() {
    ctrl = AnimationController(
        value: 0,
        vsync: this,
        duration: Duration(hours: 1),
        lowerBound: 0,
        upperBound: double.maxFinite);
    super.initState();
  }

  double get xFreq => 60;

  double get yfreq => 53;

  double get rotFreq => 46;

  @override
  Widget build(BuildContext context) {
    var level = getLevel(widget.xp);
    var previousLevelXp = getXp(level).toDouble();
    var nextLevelXp = getXp(level + 1);
    var thisLevelXpSoFar = widget.xp - previousLevelXp;
    var thisLevelXpTotal = nextLevelXp - previousLevelXp;
    double percent = thisLevelXpSoFar / thisLevelXpTotal;
    String percentText = "${(percent * 100).round()} %";
    double recentPercent;

    if (widget.recent != null) {
      recentPercent = percent;
      percent = ((thisLevelXpSoFar - widget.recent) / thisLevelXpTotal)
          .clamp(0.0, 1.0)
          .toDouble();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 50),
      child: Listener(
        onPointerDown: (details) {
          ctrl.animateWith(PassThroughSimulation());
        },
        onPointerUp: (details) {
          ctrl.animateWith(PassThroughSimulation(reverse: ctrl.value / 2));
        },
        child: AnimatedBuilder(
          animation: ctrl,
          builder: (context, _) {
            return Explode(
              explode: ctrl.value > 5,
              colors: [Colors.black, Colors.red, Colors.lightGreen.shade400],
              child: Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.identity()
                  ..translate(
                    sin(ctrl.value * xFreq) * ctrl.value,
                    sin(ctrl.value * yfreq) * ctrl.value,
                  )
                  ..rotateZ(sin(ctrl.value * rotFreq) * ctrl.value * 0.005),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                                text: widget.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                      leading: Text("$level"),
                      trailing: Text("${level + 1}"),
                      alignment: MainAxisAlignment.center,
                      progressColor: Color.lerp(Colors.lightGreen.shade400,
                          Colors.red, (ctrl.value / 5).clamp(0.0, 1.0)),
                      recentColor: Color.lerp(Colors.amber.shade600, Colors.red,
                          (ctrl.value / 5).clamp(0.0, 1.0)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
