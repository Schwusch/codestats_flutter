import 'dart:async';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/level_percent_indicator.dart';
import 'package:codestats_flutter/widgets/shimmer.dart';
import 'package:collection/collection.dart';
import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:intl/intl.dart';
import 'package:pimp_my_button/pimp_my_button.dart';
import 'package:superpower/superpower.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ProfilePage extends StatefulWidget {
  final User userModel;
  final UserBloc bloc;
  final String userName;

  const ProfilePage({
    Key key,
    @required this.userModel,
    @required this.bloc,
    @required this.userName,
  }) : super(key: key);

  @override
  ProfilePageState createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  GlobalKey<AnimatedCircularChartState> chartKey =
      GlobalKey<AnimatedCircularChartState>();
  StreamSubscription circularChartSubscription;

  @override
  void initState() {
    super.initState();
    circularChartSubscription = widget.bloc.users.listen((UserState state) {
      if (state.allUsers[widget.userName] != null) {
        chartKey.currentState.updateData(
          [createCircularStack(state.allUsers[widget.userName])],
        );
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    circularChartSubscription.cancel();
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
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    var level = getLevel(widget.userModel.totalXp);
    var previousLevelXp = getXp(level).toDouble();
    var nextLevelXp = getXp(level + 1);
    var thisLevelXpSoFar = widget.userModel.totalXp - previousLevelXp;
    var thisLevelXpTotal = nextLevelXp - previousLevelXp;

    var hoursOfDayData = $(widget.userModel.hourOfDayXps.entries
        .map((entry) => MapEntry(int.parse(entry.key), entry.value)))
      ..sort((a, b) => a.key - b.key);

    var minY = hoursOfDayData.minBy((elem) => elem.value).value;
    var maxY = hoursOfDayData.maxBy((elem) => elem.value).value;

    chartKey.currentState?.updateData([createCircularStack(widget.userModel)]);
    Map<String, List<Xp>> recentMachines =
        groupBy(widget.userModel.recentMachines, (Xp element) => element.name);

    // sort the machines by level
    widget.userModel.totalMachines.sort((a, b) => b.xp - a.xp);

    return ListView(
      children: [
        Center(
          child: PimpedButton(
            pimpedWidgetBuilder: (context, controller) {
              controller.forward(from: 0);
              return Shimmer.fromColors(
                baseColor: Colors.blueGrey.shade600,
                highlightColor: Colors.blueGrey.shade100,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: AutoSizeText(
                    "${widget.userModel.totalXp}",
                    style: TextStyle(
                      fontSize: 999,
                      fontFamily: "OCRAEXT",
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
              );
            },
            particle: DemoParticle(),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => AnimatedCircularChart(
                duration: Duration(seconds: 1),
                key: chartKey,
                size: Size.square(constraints.maxWidth * 2 / 3),
                edgeStyle: SegmentEdgeStyle.round,
                initialChartData: [],
                holeLabel: Column(
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
                            text: '${formatter.format(thisLevelXpSoFar)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    ' / ${formatter.format(thisLevelXpTotal)} XP',
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
                              ' +${formatter.format(getRecentXp(widget.userModel))} XP'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Center(
            child: Text(
              "Machines",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                fontFamily: 'OCRAEXT',
              ),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, BoxConstraints constraints) => Column(
                children: widget.userModel.totalMachines
                    .map(
                      (machine) => LevelPercentIndicator(
                            width: constraints.maxWidth * 0.7,
                            name: machine.name,
                            xp: machine.xp,
                            recent: recentMachines[machine.name]?.first?.xp,
                          ),
                    )
                    .toList(),
              ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
          child: Center(
            child: AutoSizeText(
              "Total XP per hour of day",
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                fontFamily: 'OCRAEXT',
              ),
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: LineChart(
            lines: [
              Line<MapEntry<int, int>, int, int>(
                  data: hoursOfDayData,
                  xFn: (datum) => datum.key,
                  yFn: (datum) => datum.value,
                  yAxis: ChartAxis<int>(
                      tickGenerator:
                          IntervalTickGenerator.byN((maxY / 5).floor()),
                      span: IntSpan(minY, maxY),
                      tickLabelFn: (value) => formatter.format(value)),
                  xAxis: ChartAxis<int>(
                    tickGenerator: IntervalTickGenerator.byN(6),
                    span: IntSpan(0, 23),
                  ),
                  marker: MarkerOptions(
                    shape: MarkerShapes.circle,
                    paint: PaintOptions.fill(
                      color: Colors.blue,
                    ),
                  ),
                  stroke: PaintOptions.stroke(
                      color: Colors.lightBlue, strokeWidth: 2)),
            ],
            chartPadding: EdgeInsets.fromLTRB(80, 20, 20, 30),
          ),
        ),
      ],
    );
  }
}
