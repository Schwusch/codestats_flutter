import 'package:auto_size_text/auto_size_text.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/widgets/subheader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:superpower/superpower.dart';

class Month {
  final int number;
  final Map<int, int> daysXp = {};

  Month(this.number);
}

class DayOfYearXps extends StatelessWidget {
  final User userModel;

  const DayOfYearXps({
    Key key,
    @required this.userModel,
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

    months.forEach((month) {
      var keys = month.daysXp.keys.toList()..sort();
      days.addAll(keys.map(
            (day) {
          var xpPercent = month.daysXp[day] / maxXp;

          var thenDate = DateTime(2020, month.number, day);
          var todayDate = DateTime.now();

          bool today = todayDate.month == month.number && todayDate.day == day;

          var style = TextStyle(
            color: xpPercent < 0.4 ? Colors.blueGrey[600] : Colors.grey.shade300,
            fontWeight: today ? FontWeight.bold : FontWeight.normal,
            decoration: today ? TextDecoration.underline : TextDecoration.none,
          );

          return Container(
            color: Colors.black.withOpacity(xpPercent),
            child: AspectRatio(
              aspectRatio: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    formatter.format(
                      thenDate,
                    ),
                    maxLines: 1,
                    style: style,
                  ),
                  AutoSizeText(
                    month.daysXp[day].toString(),
                    maxLines: 1,
                    style: style,
                  ),
                ],
              ),
            ),
          );
        },
      ));
    });

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SubHeader(text: "Total XP by day of year",),
        Expanded(
          child: GridView.count(
            crossAxisCount: 7,
            children: days,
            padding: EdgeInsets.only(
              bottom: 30,
              left: 8,
              right: 8,
            ),
          ),
        ),
      ],
    );
  }
}
