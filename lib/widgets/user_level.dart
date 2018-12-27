import 'package:codestats_flutter/usermodel.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserLevelWidget extends StatelessWidget {
  const UserLevelWidget({
    Key key,
    @required this.userModel,
  }) : super(key: key);

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: <Widget>[
          Chip(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            label: Text(
              "${formatter.format(userModel.totalXp)} XP",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            avatar: CircleAvatar(
              maxRadius: 100,
              backgroundColor: Colors.deepOrange.shade900,
              child: Text(
                formatter.format(getLevel(userModel.totalXp)),
                style: TextStyle(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            backgroundColor: Colors.deepOrange.shade400,
          ),
          Chip(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            label: Text(
              "${getRecentXp(userModel)} XP today",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.deepPurpleAccent.shade200,
          )
        ],
      ),
    );
  }
}
