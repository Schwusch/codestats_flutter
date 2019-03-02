import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/widgets/subheader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:superpower/superpower.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

class Month {
  final int number;
  final Map<int, int> daysXp = {};

  Month(this.number);
}

class DayOfYearXps extends StatelessWidget {
  final User userModel;
  final ScrollController scrollController;

  const DayOfYearXps({
    Key key,
    @required this.userModel,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Month> months = List.generate(12, (i) => Month(i + 1));
    final formatter = DateFormat('MMM d');
    List<Widget> days = [];

    var doyx = userModel.dayOfYearXps
        .map((key, value) => MapEntry(int.parse(key), value));

    var maxXp = $(doyx.values).max();

    doyx.keys.forEach((day) {
      var date = DateTime(2000).add(Duration(days: day - 1));
      months[date.month - 1].daysXp[date.day] = doyx[day];
    });

    months.forEach(
      (month) {
        var keys = month.daysXp.keys.toList()..sort();
        days.addAll(
          keys.map(
            (day) {
              var xpPercent = month.daysXp[day] / maxXp;

              var thenDate = DateTime(2020, month.number, day);
              var todayDate = DateTime.now();

              bool today =
                  todayDate.month == month.number && todayDate.day == day;

              var style = TextStyle(
                color: xpPercent < 0.4
                    ? Colors.blueGrey[600]
                    : Colors.grey.shade300,
                fontWeight: today ? FontWeight.bold : FontWeight.normal,
                decoration:
                    today ? TextDecoration.underline : TextDecoration.none,
              );

              var xpStr = month.daysXp[day].toString();

              return Container(
                color: Colors.black.withOpacity(xpPercent),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formatter.format(
                                thenDate,
                              ),
                              style: style.copyWith(
                                  fontSize: constraints.maxWidth * .2),
                            ),
                            Text(
                              xpStr,
                              style: style.copyWith(
                                  fontSize: 18 -
                                      xpStr.length *
                                          constraints.maxWidth *
                                          .02),
                            ),
                          ],
                        ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SubHeader(
          text: "Total XP by day of year",
        ),
        Expanded(
          child: DraggableScrollbar.semicircle(
            controller: scrollController,
            child: GridView.count(
              controller: scrollController,
              crossAxisCount: 7,
              children: days,
              padding: EdgeInsets.only(
                bottom: 30,
                left: 8,
                right: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
