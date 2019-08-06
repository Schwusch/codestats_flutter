import 'dart:async';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/tiltable_stack.dart';
import 'package:codestats_flutter/widgets/wave_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class LevelProgressCircle extends StatefulWidget {
  const LevelProgressCircle({
    Key key,
    @required this.userModel,
    @required this.bloc,
    @required this.userName,
  }) : super(key: key);

  final User userModel;
  final UserBloc bloc;
  final String userName;

  @override
  LevelProgressCircleState createState() => LevelProgressCircleState();
}

class LevelProgressCircleState extends State<LevelProgressCircle>
    with SingleTickerProviderStateMixin {
  GlobalKey<AnimatedCircularChartState> chartKey = GlobalKey();
  GlobalKey<WaveProgressState> waveKey = GlobalKey();
  StreamSubscription circularChartSubscription;

  @override
  void initState() {
    super.initState();
    circularChartSubscription =
        widget.bloc.userStateController.listen((UserState state) {
      if (state.allUsers[widget.userName] != null) {
        chartKey.currentState.updateData(
          [createCircularStack(state.allUsers[widget.userName])],
        );
      }
    });
  }

  CircularStackEntry createCircularStack(User userModel) {
    List<CircularSegmentEntry> segments = [];
    var level = getLevel(userModel.totalXp);
    var previousLevelXp = getXp(level).toDouble();
    var nextLevelXp = getXp(level + 1);
    var thisLevelXpSoFar = userModel.totalXp - previousLevelXp;
    var thisLevelXpTotal = nextLevelXp - previousLevelXp;
    var recentXp = getRecentXp(userModel).toDouble();

    bool recentXpLessThanSoFarOnLevel = recentXp < thisLevelXpSoFar;

    if (recentXpLessThanSoFarOnLevel) {
      segments.add(
        CircularSegmentEntry(
            thisLevelXpSoFar - recentXp, Colors.lightGreen[400],
            rankKey: 'completed'),
      );
      segments.add(
        CircularSegmentEntry(recentXp, Colors.amber[600], rankKey: 'recent'),
      );
    } else {
      segments.add(
        CircularSegmentEntry(thisLevelXpSoFar, Colors.amber[600],
            rankKey: 'recent'),
      );
    }

    segments.add(
      CircularSegmentEntry(
          (thisLevelXpTotal - thisLevelXpSoFar).toDouble(), Colors.grey[300],
          rankKey: 'Remaining'),
    );

    return CircularStackEntry(segments);
  }

  @override
  dispose() {
    super.dispose();
    circularChartSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final level = getLevel(widget.userModel.totalXp);
    final previousLevelXp = getXp(level).toDouble();
    final nextLevelXp = getXp(level + 1);
    final thisLevelXpSoFar = widget.userModel.totalXp - previousLevelXp;
    final thisLevelXpTotal = nextLevelXp - previousLevelXp;

    chartKey.currentState?.updateData([createCircularStack(widget.userModel)]);
    waveKey.currentState?.update(thisLevelXpSoFar / thisLevelXpTotal);

    /*var z = depth?.value ?? 0;
    var textShadow = Shadow(
      color: Colors.grey.withAlpha((z * 50 + 100).toInt()),
      offset: Offset(yaw * 20, -pitch * 20 + 5),
      blurRadius: z.clamp(0.0, double.maxFinite) * 4 + 1,
    );*/

    return LayoutBuilder(
      builder: (context, constraints) => TiltableStack(
        alignment: Alignment.center,
        children: [
          AnimatedCircularChart(
            duration: Duration(seconds: 1),
            key: chartKey,
            size: Size.square(constraints.maxWidth * 3 / 4),
            edgeStyle: SegmentEdgeStyle.round,
            initialChartData: [],
            holeLabel: Container(),
          ),
          SizedBox.fromSize(
            size: Size.square(constraints.maxWidth * 3 / 4 - 80),
            child: Material(
              elevation: 4,
              color: Colors.grey.shade100,
              shape: CircleBorder(),
              child: Stack(alignment: AlignmentDirectional.center, children: [
                WaveProgress(
                  constraints.maxWidth * 2 / 3,
                  Colors.blueGrey.shade200.withAlpha(100),
                  thisLevelXpSoFar / thisLevelXpTotal,
                  key: waveKey,
                ),
              ]),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LEVEL',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              Text(
                '$level',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text.rich(
                  TextSpan(
                      text: '${formatNumber(thisLevelXpSoFar)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: ' / ${formatNumber(thisLevelXpTotal)} XP',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      ]),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '12h ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Icon(Icons.timer),
                    Text(
                      ' +${formatNumber(getRecentXp(widget.userModel))} XP',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
