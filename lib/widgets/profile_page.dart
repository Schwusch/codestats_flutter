import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:codestats_flutter/sequence_animation.dart';
import 'package:codestats_flutter/utils.dart' show formatNumber;
import 'package:codestats_flutter/widgets/level_percent_indicator.dart';
import 'package:codestats_flutter/widgets/level_progress_circle.dart';
import 'package:codestats_flutter/widgets/spotlight.dart';
import 'package:codestats_flutter/widgets/subheader.dart';
import 'package:codestats_flutter/widgets/total_xp_header.dart';
import 'package:collection/collection.dart';
import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:superpower/superpower.dart';

class ProfilePage extends StatefulWidget {
  final User userModel;
  final String userName;

  const ProfilePage({
    Key key,
    @required this.userModel,
    @required this.userName,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  SequenceAnimation sequence;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    sequence = SequenceAnimationBuilder()
        .addAnimatable(
          animatable: Tween<Offset>(
            begin: Offset(-2.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
          from: Duration(milliseconds: 200),
          to: Duration(milliseconds: 500),
          tag: "totalXPtext",
        )
        .addAnimatable(
          animatable: Tween<Offset>(
            begin: Offset(2.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
          from: Duration(milliseconds: 400),
          to: Duration(milliseconds: 700),
          tag: "average",
        )
        .addAnimatable(
          animatable: Tween<Offset>(
            begin: Offset(-2.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
          from: Duration(milliseconds: 500),
          to: Duration(milliseconds: 800),
          tag: "machines",
        )
        .addAnimatable(
          animatable: Tween<Offset>(
            begin: Offset(2.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
          from: Duration(milliseconds: 700),
          to: Duration(milliseconds: 1000),
          tag: "hourofday",
        )
        .animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc bloc = BlocProvider.of(context);
    final formatter = DateFormat('MMMM d yyyy');

    final DateTime registered = DateTime.parse(widget.userModel.registered);

    DateTime now = DateTime.now();
    Duration userTime = now.difference(registered);

    var hoursOfDayData = $(widget.userModel.hourOfDayXps.entries
        .map((entry) => MapEntry(int.parse(entry.key), entry.value)))
      ..sort((a, b) => a.key - b.key);

    var minY = hoursOfDayData.minBy((elem) => elem.value).value;
    var maxY = hoursOfDayData.maxBy((elem) => elem.value).value;

    Map<String, List<Xp>> recentMachines =
        groupBy(widget.userModel.recentMachines, (Xp element) => element.name);

    // sort the machines by level
    widget.userModel.totalMachines.sort((a, b) => b.xp - a.xp);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TotalXp(totalXp: widget.userModel.totalXp),
          SlideTransition(
            position: sequence["totalXPtext"],
            child: Text("XP since ${formatter.format(registered)}"),
          ),
          SlideTransition(
            position: sequence["average"],
            child: Text(
                "Average ${(widget.userModel.totalXp / userTime.inDays).round()} XP per day"),
          ),
          LevelProgressCircle(
            userModel: widget.userModel,
            bloc: bloc,
            userName: widget.userName,
          ),
          SlideTransition(
            position: sequence["machines"],
            child: SubHeader(
              text: "Machines",
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
          SlideTransition(
            position: sequence["hourofday"],
            child: SubHeader(
              text: "Total XP per hour of day",
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
                        tickLabelFn: (value) => formatNumber(value)),
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
      ),
    );
  }
}
