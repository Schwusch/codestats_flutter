import 'package:charts_common/common.dart';
import 'package:codestats_flutter/models/user/day_language_xps.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DayLanguageXpsWidget extends StatelessWidget {
  const DayLanguageXpsWidget({
    Key key,
    @required this.userModel,
    @required this.languages,
    @required this.colors,
  }) : super(key: key);

  final User userModel;
  final Map<String, List<DayLanguageXps>> languages;
  final Map<String, charts.Color> colors;

  @override
  Widget build(BuildContext context) {

    return Padding(
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
        animationDuration: Duration(milliseconds: 150),
        defaultInteractions: false,
        defaultRenderer: new charts.BarRendererConfig<DateTime>(
          groupingType: charts.BarGroupingType.stacked,
        ),
        domainAxis: charts.DateTimeAxisSpec(
          usingBarRenderer: true,
          renderSpec: SmallTickRendererSpec<DateTime>(
            labelAnchor: TickLabelAnchor.centered,
            labelOffsetFromTickPx: 0,

          ),
          tickProviderSpec: DayTickProviderSpec(increments: List.generate(7, (i) => i + 1))
        ),
        behaviors: [
          charts.LinePointHighlighter(showHorizontalFollowLine: LinePointHighlighterFollowLineType.nearest),
          charts.SelectNearest(),
          charts.DomainHighlighter(),
          charts.SeriesLegend(
            entryTextStyle: TextStyleSpec(color: charts.ColorUtil.fromDartColor(Colors.black)),
            measureFormatter: (xp) => xp != null ? "${xp?.round()} XP" : "",
            legendDefaultMeasure: LegendDefaultMeasure.sum,
            showMeasures: true,
            position: charts.BehaviorPosition.top,
            outsideJustification: charts.OutsideJustification.endDrawArea,
            horizontalFirst: false,
            desiredMaxRows: (languages.keys.length / 2).floor(),
          ),
        ],
      ),
    );
  }
}
