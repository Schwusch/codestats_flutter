import 'package:charts_common/common.dart';
import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/day_language_xps.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DayLanguageXpsWidget extends StatelessWidget {
  const DayLanguageXpsWidget({
    Key key,
    @required this.userModel,
  }) : super(key: key);

  final User userModel;

  @override
  Widget build(BuildContext context) {
    final UserBloc bloc = BlocProvider.of(context);

    Map<String, List<DayLanguageXps>> languages = groupBy(
      userModel.dayLanguageXps,
      (DayLanguageXps element) => element.language,
    );

    if (languages.isEmpty) {
      return Center(
        child: Text("No recent activity :("),
      );
    }

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: charts.TimeSeriesChart(
        languages.values
            .map(
              (dlx) => charts.Series<DayLanguageXps, DateTime>(
                    id: dlx.first.language,
                    domainFn: (DayLanguageXps elem, _) =>
                        DateTime.parse(elem.date),
                    measureFn: (DayLanguageXps elem, _) => elem.xp,
                    data: dlx,
                    colorFn: (elem, _) => bloc.languageColor(elem.language),
                  ),
            )
            .toList(),
        animate: true,
        animationDuration: Duration(milliseconds: 800),
        defaultInteractions: false,
        defaultRenderer: charts.BarRendererConfig<DateTime>(
          groupingType: charts.BarGroupingType.stacked,
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
              (value) => "${value.round()} XP"),
        ),
        domainAxis: charts.DateTimeAxisSpec(
          usingBarRenderer: true,
          renderSpec: SmallTickRendererSpec<DateTime>(
            labelAnchor: TickLabelAnchor.centered,
            labelOffsetFromTickPx: 0,
          ),
          tickProviderSpec: DayTickProviderSpec(
            increments: [1],
          ),
        ),
        behaviors: [
          charts.LinePointHighlighter(
              showHorizontalFollowLine:
                  LinePointHighlighterFollowLineType.nearest),
          charts.SelectNearest(
            eventTrigger: SelectionTrigger.tapAndDrag,
          ),
          charts.DomainHighlighter(),
          charts.SeriesLegend(
            entryTextStyle: TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.black),
            ),
            measureFormatter: (xp) => xp != null ? "${xp?.round()} XP" : "",
            legendDefaultMeasure: LegendDefaultMeasure.sum,
            showMeasures: true,
            position: charts.BehaviorPosition.top,
            outsideJustification: charts.OutsideJustification.start,
            horizontalFirst: false,
            desiredMaxRows: (languages.keys.length / 2).ceil(),
          ),
        ],
      ),
    );
  }
}
