import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/widgets/level_percent_indicator.dart';
import 'package:flutter/material.dart';

class LanguageLevelPage extends StatelessWidget {
  final UserModel userModel;

  const LanguageLevelPage({Key key, @required this.userModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    userModel.totalLangs.sort((a, b) => b.xp - a.xp);

    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) => ListView.builder(
            padding: EdgeInsets.only(top: 24, bottom: 24),
            itemCount: userModel.totalLangs.length,
            itemBuilder: (context, index) => LevelPercentIndicator(
                  width: constraints.maxWidth * 0.7,
                  name: userModel.totalLangs[index].name,
                  xp: userModel.totalLangs[index].xp,
                ),
          ),
    );
  }
}
