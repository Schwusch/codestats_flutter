import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/xp_chip.dart';
import 'package:flutter/material.dart';

class UserLevelWidget extends StatelessWidget {
  const UserLevelWidget({
    Key key,
    @required this.userModel,
  }) : super(key: key);

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: <Widget>[
          XpChip(
            showLevel: true,
            xp: userModel.totalXp,
            avatarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.deepOrange.shade400,
          ),
          XpChip(
            xp: getRecentXp(userModel),
            backgroundColor: Colors.deepPurpleAccent.shade200,
            prefix: "+",
          ),
        ],
      ),
    );
  }
}
