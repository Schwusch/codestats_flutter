import 'dart:async';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:intl/intl.dart';

class LevelProgressCircle extends StatefulWidget {
  const LevelProgressCircle({
    Key key,
    @required this.formatter,
    @required this.userModel,
    @required this.bloc,
    @required this.userName,
  }) : super(key: key);

  final NumberFormat formatter;
  final User userModel;
  final UserBloc bloc;
  final String userName;

  @override
  LevelProgressCircleState createState() {
    return LevelProgressCircleState();
  }
}

class LevelProgressCircleState extends State<LevelProgressCircle> {
  GlobalKey<AnimatedCircularChartState> chartKey =
  GlobalKey<AnimatedCircularChartState>();
  StreamSubscription circularChartSubscription;

  @override
  void initState() {
    super.initState();
    circularChartSubscription = widget.bloc.userStateController.listen((UserState state) {
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
        CircularSegmentEntry(recentXp, Colors.amber[700], rankKey: 'recent'),
      );
    } else {
      segments.add(
        CircularSegmentEntry(thisLevelXpSoFar, Colors.amber[700],
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
    var level = getLevel(widget.userModel.totalXp);
    var previousLevelXp = getXp(level).toDouble();
    var nextLevelXp = getXp(level + 1);
    var thisLevelXpSoFar = widget.userModel.totalXp - previousLevelXp;
    var thisLevelXpTotal = nextLevelXp - previousLevelXp;
    chartKey.currentState?.updateData([createCircularStack(widget.userModel)]);

    return LayoutBuilder(
      builder: (context, constraints) => AnimatedCircularChart(
        duration: Duration(seconds: 1),
        key: chartKey,
        size: Size.square(constraints.maxWidth * 2 / 3),
        edgeStyle: SegmentEdgeStyle.round,
        initialChartData: [],
        holeLabel: SizedBox.fromSize(
          size: Size.square(constraints.maxWidth * 2 / 3 - 73),
          child: Material(
            elevation: 4,
            color: Colors.grey.shade100,
            shape: CircleBorder(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LEVEL',
                  style: TextStyle(
                    color: Colors.blueGrey[600],
                  ),
                ),
                Text(
                  '$level',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text.rich(
                    TextSpan(
                        text: '${widget.formatter.format(thisLevelXpSoFar)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text:
                            ' / ${widget.formatter.format(thisLevelXpTotal)} XP',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          )
                        ]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('12h '),
                      Icon(Icons.timer),
                      Text(
                          ' +${widget.formatter.format(getRecentXp(widget.userModel))} XP'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}