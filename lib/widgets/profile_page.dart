import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:codestats_flutter/sequence_animation.dart';
import 'package:codestats_flutter/utils.dart' show formatNumber;
import 'package:codestats_flutter/widgets/level_percent_indicator.dart';
import 'package:codestats_flutter/widgets/level_progress_circle.dart';
import 'package:codestats_flutter/widgets/subheader.dart';
import 'package:codestats_flutter/widgets/total_xp_header.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final UserWrap user;

  const ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late SequenceAnimation<Offset> sequence;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    sequence = SequenceAnimationBuilder<Offset>()
        .addAnimatable(
          animatable: Tween<Offset>(
            begin: const Offset(-2.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
          from: const Duration(milliseconds: 200),
          to: const Duration(milliseconds: 500),
          tag: "totalXPtext",
        )
        .addAnimatable(
          animatable: Tween<Offset>(
            begin: const Offset(2.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
          from: const Duration(milliseconds: 400),
          to: const Duration(milliseconds: 700),
          tag: "average",
        )
        .addAnimatable(
          animatable: Tween<Offset>(
            begin: const Offset(-2.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
          from: const Duration(milliseconds: 500),
          to: const Duration(milliseconds: 800),
          tag: "machines",
        )
        .addAnimatable(
          animatable: Tween<Offset>(
            begin: const Offset(2.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
          from: const Duration(milliseconds: 700),
          to: const Duration(milliseconds: 1000),
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
    final UserBloc bloc = context.read<UserBloc>();
    final formatter = DateFormat('MMMM d yyyy');

    DateTime registered;
    try {
      registered = DateTime.parse(widget.user.data!.registered);
    } catch (e) {
      return Container();
    }

    Duration userTime = DateTime.now().difference(registered);

    var hoursOfDayData = widget.user.data!.hourOfDayXps.entries
        .map((entry) => MapEntry(int.parse(entry.key), entry.value))
        .toList()
      ..sort((a, b) => a.key - b.key);

    var minY = hoursOfDayData
        .reduce((curr, next) => curr.value < next.value ? curr : next)
        .value;
    var maxY = hoursOfDayData
        .reduce((curr, next) => curr.value > next.value ? curr : next)
        .value;

    Map<String, List<Xp>> recentMachines =
        groupBy(widget.user.data!.recentMachines, (Xp element) => element.name);

    // sort the machines by level
    widget.user.data!.totalMachines.sort((a, b) => b.xp - a.xp);

    List<Color> gradientColors = [
      Colors.blueGrey.shade300,
      Colors.blueGrey.shade100,
      Colors.blueGrey.shade100,
      Colors.blueGrey.shade300,
      Colors.blueGrey.shade300,
    ];

    var spots = hoursOfDayData
        .map((value) => FlSpot(value.key.toDouble(), value.value.toDouble()))
        .toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TotalXp(totalXp: widget.user.data!.totalXp),
          SlideTransition(
            position: sequence["totalXPtext"],
            child: Text("XP since ${formatter.format(registered)}"),
          ),
          SlideTransition(
            position: sequence["average"],
            child: Text(
                "Average ${((widget.user.data?.totalXp ?? 0) / (userTime.inDays == 0 ? 1 : userTime.inDays)).round()} XP per day"),
          ),
          LevelProgressCircle(
            user: widget.user,
            bloc: bloc,
          ),
          if (widget.user.data!.totalMachines.isNotEmpty)
            SlideTransition(
              position: sequence["machines"],
              child: const SubHeader(
                text: "Machines",
              ),
            ),
          LayoutBuilder(
            builder: (context, BoxConstraints constraints) => Column(
              children: widget.user.data!.totalMachines
                  .map(
                    (machine) => LevelPercentIndicator(
                      width: constraints.maxWidth * 0.7,
                      name: machine.name,
                      xp: machine.xp,
                      recent: recentMachines[machine.name]?.firstOrNull?.xp,
                    ),
                  )
                  .toList(),
            ),
          ),
          if (spots.isNotEmpty)
            SlideTransition(
              position: sequence["hourofday"],
              child: const SubHeader(
                text: "Total XP per hour of day",
              ),
            ),
          if (spots.isNotEmpty)
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 18.0, left: 12.0, top: 24, bottom: 12),
                child: LineChart(
                  LineChartData(
                    maxX: 23,
                    minX: 0,
                    maxY: maxY.toDouble(),
                    minY: (minY.toDouble() - (maxY - minY) * 0.05),
                    lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.white.withOpacity(0.5),
                        ),
                        touchSpotThreshold: 10),
                    gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        getDrawingVerticalLine: (value) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                        getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                        verticalInterval: (maxY - minY) / 3),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 6,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  color: Color(0xff68737d),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: maxY.toString().length * 8.0,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              formatNumber(value),
                              style: const TextStyle(
                                color: Color(0xff67727d),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                        show: false,
                        border: Border.all(
                            color: const Color(0xff37434d), width: 1)),
                    lineBarsData: [
                      LineChartBarData(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                        spots: spots,
                        isCurved: true,
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ____, _____) =>
                              FlDotCirclePainter(
                            color: Colors.blueGrey,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                              colors: gradientColors
                                  .map((color) => color.withOpacity(0.3))
                                  .toList()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
