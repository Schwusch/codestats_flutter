import 'package:codestats_flutter/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DayLanguageXpsWidget extends StatelessWidget {
  const DayLanguageXpsWidget({
    Key key,
    @required this.userModel,
    @required this.languages,
    @required this.colors,
  }) : super(key: key);

  final UserModel userModel;
  final Map<String, List<DayLanguageXps>> languages;
  final Map<String, charts.Color> colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: charts.TimeSeriesChart(
          languages.values
              .map((dlx) => charts.Series<DayLanguageXps, DateTime>(
            id: dlx.first.language,
            domainFn: (DayLanguageXps elem, _) =>
                DateTime.parse(elem.date),
            measureFn: (DayLanguageXps elem, _) => elem.xp,
            data: dlx,
            colorFn: (elem, _) => colors[elem.language],
          ))
              .toList(),
          animate: true,
          defaultInteractions: false,
          defaultRenderer: new charts.BarRendererConfig<DateTime>(
            groupingType: charts.BarGroupingType.stacked,
          ),
          domainAxis: new charts.DateTimeAxisSpec(
              usingBarRenderer: true, showAxisLine: true),
          behaviors: [
            charts.SelectNearest(),
            charts.DomainHighlighter(),
            charts.SeriesLegend(
              position: charts.BehaviorPosition.top,
              outsideJustification: charts.OutsideJustification.endDrawArea,
              horizontalFirst: false,
              desiredMaxRows: (languages.keys.length / 2).floor(),
            ),
          ],
        ),
      ),
    );
  }
}