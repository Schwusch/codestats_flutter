import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:codestats_flutter/widgets/level_percent_indicator.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class LanguageLevelPage extends StatelessWidget {
  final User userModel;

  const LanguageLevelPage({Key key, @required this.userModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    userModel.totalLangs.sort((a, b) => b.xp - a.xp);
    Map<String, List<Xp>> recentLanguages =
        groupBy(userModel.recentLangs, (Xp element) => element.name);

    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) => ListView.builder(
            padding: EdgeInsets.only(top: 24, bottom: 24),
            itemCount: userModel.totalLangs.length,
            itemBuilder: (context, index) => LevelPercentIndicator(
                  width: constraints.maxWidth * 0.7,
                  name: userModel.totalLangs[index].name,
                  xp: userModel.totalLangs[index].xp,
                  recent: recentLanguages[userModel.totalLangs[index].name]
                      ?.first
                      ?.xp,
                ),
          ),
    );
  }
}
