import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LanguageLevelPage extends StatelessWidget {
  final UserModel userModel;

  const LanguageLevelPage({Key key, @required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    userModel.totalLangs.sort((a, b) => b.xp - a.xp);

    return ListView.builder(
      padding: EdgeInsets.only(top: 24, bottom: 24),
      itemCount: userModel.totalLangs.length,
      itemBuilder: (context, index) {
        final formatter = NumberFormat("#,###");
        final lang = userModel.totalLangs[index];

        var level = getLevel(lang.xp);
        var previousLevelXp = getXp(level).toDouble();
        var nextLevelXp = getXp(level + 1);
        var thisLevelXpSoFar = lang.xp - previousLevelXp;
        var thisLevelXpTotal = nextLevelXp - previousLevelXp;
        double percent = thisLevelXpSoFar / thisLevelXpTotal;
        String percentText = "${(percent * 100).floor()} %";

        return LayoutBuilder(
          builder: (context, constraints) => Column(
                children: [
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                              text:  lang.name,
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(
                            text:  " level $level (${formatter.format(lang.xp)} XP)",
                          ),
                        ]),
                  ),
                  LinearPercentIndicator(
                    width: constraints.maxWidth * 0.7,
                    lineHeight: 14.0,
                    percent: percent,
                    center: Text(
                      percentText,
                      style: new TextStyle(fontSize: 12.0),
                    ),
                    leading: Text("$level"),
                    trailing: Text("${level + 1}"),
                    alignment: MainAxisAlignment.center,
                    progressColor: Colors.green,
                  ),
                ],
              ),
        );
      },
    );
  }
}
