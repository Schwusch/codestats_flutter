import 'package:charts_common/common.dart'
    show
        LinePointHighlighterFollowLineType,
        SelectionTrigger,
        SmallTickRendererSpec,
        TickLabelAnchor,
        TextStyleSpec,
        LegendDefaultMeasure,
        DayTickProviderSpec;
import 'package:charts_flutter/flutter.dart' as charts
    show
        TimeSeriesChart,
        Series,
        BarRendererConfig,
        BarGroupingType,
        NumericAxisSpec,
        BasicNumericTickFormatterSpec,
        LinePointHighlighter,
        DomainHighlighter,
        SeriesLegend,
        DateTimeAxisSpec,
        ColorUtil,
        BehaviorPosition,
        OutsideJustification,
        SelectNearest;
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/day_language_xps.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:collection/collection.dart' show groupBy;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DayLanguageXpsWidget extends StatefulWidget {
  const DayLanguageXpsWidget({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  final User? userModel;

  @override
  _DayLanguageXpsWidgetState createState() => _DayLanguageXpsWidgetState();
}

class _DayLanguageXpsWidgetState extends State<DayLanguageXpsWidget> {
  bool animate = false;

  @override
  void didUpdateWidget(DayLanguageXpsWidget oldWidget) {
    animate = true;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserBloc>();
    if (widget.userModel?.dayLanguageXps.isEmpty ?? true) {
      return const Center(
        child: Text("No recent activity :("),
      );
    }

    var series = groupBy<DayLanguageXps, String>(
            widget.userModel!.dayLanguageXps, (elem) => elem.language)
        .values
        .map((dlx) => charts.Series<DayLanguageXps, DateTime>(
              id: dlx.first.language,
              domainFn: domainFn,
              measureFn: measureFn,
              data: dlx,
              colorFn: (elem, _) => bloc.languageColor(elem.language),
            ))
        .toList();

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: charts.TimeSeriesChart(
          series,
          animate: animate,
          animationDuration: const Duration(milliseconds: 800),
          defaultInteractions: false,
          defaultRenderer: charts.BarRendererConfig<DateTime>(
            groupingType: charts.BarGroupingType.stacked,
          ),
          primaryMeasureAxis: charts.NumericAxisSpec(
            tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                (value) => "${value?.round()} XP"),
          ),
          domainAxis: const charts.DateTimeAxisSpec(
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
              measureFormatter: (xp) => xp != null ? "${xp.round()} XP" : "",
              legendDefaultMeasure: LegendDefaultMeasure.sum,
              showMeasures: true,
              position: charts.BehaviorPosition.top,
              outsideJustification: charts.OutsideJustification.start,
              horizontalFirst: false,
              desiredMaxRows: (series.length / 2).ceil(),
            ),
          ],
        ));
  }
}

DateTime domainFn(DayLanguageXps elem, int? _) => DateTime.parse(elem.date);

int measureFn(DayLanguageXps elem, int? _) => elem.xp;
