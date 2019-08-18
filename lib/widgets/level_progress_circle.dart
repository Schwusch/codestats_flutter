import 'dart:async';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/note_animation/animated_note.dart';
import 'package:codestats_flutter/widgets/note_animation/note_painter.dart';
import 'package:codestats_flutter/widgets/tiltable_stack.dart';
import 'package:codestats_flutter/widgets/wave_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class LevelProgressCircle extends StatefulWidget {
  const LevelProgressCircle({
    Key key,
    @required this.bloc,
    @required this.user,
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
  GlobalKey<AnimatedNoteState> noteKey = GlobalKey();
  StreamSubscription circularChartSubscription;
  final channel = EventChannel('fourierStream');

  @override
  void initState() {
    super.initState();
    circularChartSubscription =
        widget.bloc.currentUser.listen((UserWrap state) {
      if (state.data != null) {
        chartKey.currentState.updateData(
          [createCircularStack(state.data)],
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
    final level = getLevel(widget.user.data.totalXp);
    final previousLevelXp = getXp(level).toDouble();
    final nextLevelXp = getXp(level + 1);
    final thisLevelXpSoFar = widget.user.data.totalXp - previousLevelXp;
    final thisLevelXpTotal = nextLevelXp - previousLevelXp;

    chartKey.currentState?.updateData([createCircularStack(widget.user.data)]);
    waveKey.currentState?.update(thisLevelXpSoFar / thisLevelXpTotal);

    return LayoutBuilder(
      builder: (context, constraints) => StreamBuilder<dynamic>(
          stream: channel.receiveBroadcastStream(),
          builder: (context, snapshot) {
            var note = snapshot.data ?? -1;
            noteKey.currentState?.update(note);
            return TiltableStack(
              alignment: Alignment.center,
              children: [
                if (snapshot.hasData)
                  SizedBox.fromSize(
                    size: Size.square(constraints.maxWidth * 3 / 4 - 57),
                    child: AnimatedNote(
                      key: noteKey,
                      note: note,
                    ),
                  ),
                AnimatedCircularChart(
                  duration: Duration(seconds: 1),
                  key: chartKey,
                  size: Size.square(constraints.maxWidth * 3 / 4),
                  edgeStyle: SegmentEdgeStyle.round,
                  initialChartData: [],
                  holeLabel: Container(),
                ),
                SizedBox.fromSize(
                  key: ValueKey("foo"),
                  size: Size.square(constraints.maxWidth * 3 / 4 - 80),
                  child: Material(
                    elevation: 4,
                    color: Colors.grey.shade100,
                    shape: CircleBorder(),
                    child: WaveProgress(
                      constraints.maxWidth * 2 / 3,
                      Colors.blueGrey.shade200.withAlpha(100),
                      thisLevelXpSoFar / thisLevelXpTotal,
                      key: waveKey,
                      frequency: note,
                    ),
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
                            ' +${formatNumber(getRecentXp(widget.user.data))} XP',
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
            );
          }),
    );
  }
}
