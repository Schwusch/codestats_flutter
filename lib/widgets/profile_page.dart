import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/user_level.dart';
import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:intl/intl.dart';
import 'package:superpower/superpower.dart';

class ProfilePage extends StatelessWidget {
  final UserModel userModel;

  const ProfilePage({
    Key key,
    @required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    var level = getLevel(userModel.totalXp);
    var previousLevelXp = getXp(level).toDouble();
    var nextLevelXp = getXp(level + 1);
    var thisLevelXpSoFar = userModel.totalXp - previousLevelXp;
    var thisLevelXpTotal = nextLevelXp - previousLevelXp;
    var recentXp = getRecentXp(userModel).toDouble();

    bool recentXpLessThanSoFarOnLevel = recentXp < thisLevelXpSoFar;

    List<CircularSegmentEntry> segments = [];

    var hoursOfDayData = $(userModel.hourOfDayXps.entries
        .map((entry) => MapEntry(int.parse(entry.key), entry.value)))
      ..sort((a, b) => a.key - b.key);

    var minY = hoursOfDayData.minBy((elem) => elem.value).value;
    var maxY = hoursOfDayData.maxBy((elem) => elem.value).value;

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

    return ListView(
      children: <Widget>[
        UserLevelWidget(
          userModel: userModel,
        ),
        AnimatedCircularChart(
          size: Size.square(250),
          edgeStyle: SegmentEdgeStyle.round,
          initialChartData: [
            CircularStackEntry(segments),
          ],
          holeLabel:
              '${((thisLevelXpSoFar / thisLevelXpTotal) * 100).floor()}% of level ${level + 1}',
          labelStyle: new TextStyle(
            color: Colors.blueGrey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        Center(
          child: Text("Total XP per hour of day"),
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
