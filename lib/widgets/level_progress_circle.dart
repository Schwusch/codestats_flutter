import 'dart:async';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/utils.dart';
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
  LevelProgressCircleState createState() {
    return LevelProgressCircleState();
  }
}

class LevelProgressCircleState extends State<LevelProgressCircle>
    with SingleTickerProviderStateMixin {
  GlobalKey<AnimatedCircularChartState> chartKey =
      GlobalKey<AnimatedCircularChartState>();
  GlobalKey<WaveProgressState> waveKey = GlobalKey();
  StreamSubscription circularChartSubscription;
  AnimationController _controller;
  Animation<double> tilt;
  Animation<double> depth;
  double pitch = 0;
  double yaw = 0;

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
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this)
      ..addListener(() {
        setState(() {
          if (tilt != null) {
            pitch *= tilt.value;
            yaw *= tilt.value;
          }
        });
      });
    _controller.forward(from: 1.0);
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

  cancelPan() {
    tilt = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);
    depth = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.5, 0.0, 0.26, 1.0),
      ),
    );
    _controller.forward();
  }

  startPan() {
    tilt = null;
    depth = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(1.0, 0.0, 1.0, 1.0),
      ),
    );
    _controller.reverse();
  }

  updatePan(DragUpdateDetails drag) {
    setState(() {
      var size = MediaQuery.of(context).size;
      pitch += drag.delta.dy * (1 / size.height);
      yaw -= drag.delta.dx * (1 / size.width);
    });
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

    var z = depth?.value ?? 0;
    var textShadow = Shadow(
      color: Colors.grey.withAlpha((z * 50 + 100).toInt()),
      offset: Offset(yaw * 14, -pitch * 14 + 5),
      blurRadius: z * 4 + 1,
    );

    return GestureDetector(
      onPanUpdate: updatePan,
      onPanEnd: (_) => cancelPan(),
      onPanCancel: cancelPan,
      onPanDown: (_) => startPan(),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
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
                    shadows: [
                      if ((depth?.value ?? 0) > 0.1)
                        textShadow
                    ],
                  ),
                ),
                Text(
                  '$level',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      if ((depth?.value ?? 0) > 0.1)
                        textShadow
                    ],
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
                          shadows: [
                            if ((depth?.value ?? 0) > 0.1)
                              textShadow
                          ],
                        ),
                        children: [
                          TextSpan(
                            text: ' / ${formatNumber(thisLevelXpTotal)} XP',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              shadows: [
                                if ((depth?.value ?? 0) > 0.1)
                                  textShadow
                              ],
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
                          shadows: [
                            if ((depth?.value ?? 0) > 0.1)
                              textShadow
                          ],
                        ),
                      ),
                      Icon(Icons.timer),
                      Text(
                        ' +${formatNumber(getRecentXp(widget.userModel))} XP',
                        style: TextStyle(
                          color: Colors.black,
                          shadows: [
                            if ((depth?.value ?? 0) > 0.1)
                              textShadow
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ]
              .asMap()
              .map(
                (i, element) => MapEntry(
                  i,
                  Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(pitch)
                      ..rotateY(yaw)
                      ..translate(-yaw * i * 50, pitch * i * 50, 0)
                      ..scale((depth?.value ?? 0) * (i + 1) * 0.05 + 1),
                    child: element,
                    alignment: FractionalOffset.center,
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }
}
