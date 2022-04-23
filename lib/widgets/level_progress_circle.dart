import 'dart:async';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/tiltable_stack.dart';
import 'package:codestats_flutter/widgets/wave_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:circular_chart_flutter/circular_chart_flutter.dart';

class LevelProgressCircle extends StatefulWidget {
  const LevelProgressCircle({
    Key? key,
    required this.bloc,
    required this.user,
  }) : super(key: key);

  final UserBloc bloc;
  final UserWrap user;

  @override
  LevelProgressCircleState createState() => LevelProgressCircleState();
}

class LevelProgressCircleState extends State<LevelProgressCircle>
    with SingleTickerProviderStateMixin {
  GlobalKey<AnimatedCircularChartState> chartKey = GlobalKey();
  GlobalKey<WaveProgressState> waveKey = GlobalKey();
  late StreamSubscription circularChartSubscription;
  final channel = const EventChannel('fourierStream');

  @override
  void initState() {
    super.initState();
    circularChartSubscription =
        widget.bloc.currentUser.listen((UserWrap state) {
      if (state.data != null) {
        chartKey.currentState?.updateData(
          [createCircularStack(state.data!)],
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
    final level = getLevel(widget.user.data!.totalXp);
    final previousLevelXp = getXp(level).toDouble();
    final nextLevelXp = getXp(level + 1);
    final thisLevelXpSoFar = widget.user.data!.totalXp - previousLevelXp;
    final thisLevelXpTotal = nextLevelXp - previousLevelXp;

    chartKey.currentState?.updateData([createCircularStack(widget.user.data!)]);
    waveKey.currentState?.update(thisLevelXpSoFar / thisLevelXpTotal);

    return LayoutBuilder(
        builder: (context, constraints) => TiltableStack(
              alignment: Alignment.center,
              children: [
                AnimatedCircularChart(
                  duration: const Duration(seconds: 1),
                  key: chartKey,
                  size: Size.square(constraints.maxWidth * 3 / 4),
                  edgeStyle: SegmentEdgeStyle.round,
                  initialChartData: const [],
                ),
                SizedBox.fromSize(
                  key: const ValueKey("foo"),
                  size: Size.square(constraints.maxWidth * 3 / 4 - 80),
                  child: Material(
                    elevation: 4,
                    color: Colors.grey.shade100,
                    shape: const CircleBorder(),
                    child: WaveProgress(
                      constraints.maxWidth * 2 / 3,
                      Colors.blueGrey.shade200.withAlpha(100),
                      thisLevelXpSoFar / thisLevelXpTotal,
                      key: waveKey,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'LEVEL',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '$level',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text.rich(
                        TextSpan(
                            text: formatNumber(thisLevelXpSoFar),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: ' / ${formatNumber(thisLevelXpTotal)} XP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              )
                            ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '12h ',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const Icon(Icons.timer),
                          Text(
                            ' +${formatNumber(getRecentXp(widget.user.data!))} XP',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ));
  }
}
