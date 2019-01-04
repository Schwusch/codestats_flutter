import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:codestats_flutter/widgets/level_percent_indicator.dart';
import 'package:codestats_flutter/widgets/level_progress_circle.dart';
import 'package:codestats_flutter/widgets/subheader.dart';
import 'package:codestats_flutter/widgets/total_xp_header.dart';
import 'package:collection/collection.dart';
import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:superpower/superpower.dart';

class ProfilePage extends StatelessWidget {
  final User userModel;
  final String userName;

  const ProfilePage({
    Key key,
    @required this.userModel,
    @required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    final UserBloc bloc = BlocProvider.of(context);

    var hoursOfDayData = $(userModel.hourOfDayXps.entries
        .map((entry) => MapEntry(int.parse(entry.key), entry.value)))
      ..sort((a, b) => a.key - b.key);

    var minY = hoursOfDayData.minBy((elem) => elem.value).value;
    var maxY = hoursOfDayData.maxBy((elem) => elem.value).value;

    Map<String, List<Xp>> recentMachines =
        groupBy(userModel.recentMachines, (Xp element) => element.name);

    // sort the machines by level
    userModel.totalMachines.sort((a, b) => b.xp - a.xp);

    return ListView(
      children: [
        TotalXp(totalXp: userModel.totalXp),
        LevelProgressCircle(
          formatter: formatter,
          userModel: userModel,
          bloc: bloc,
          userName: userName,
        ),
        SubHeader(text: "Machines",),
        LayoutBuilder(
          builder: (context, BoxConstraints constraints) => Column(
                children: userModel.totalMachines
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
        SubHeader(text: "Total XP per hour of day",),
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
