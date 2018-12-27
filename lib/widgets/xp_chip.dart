import 'package:codestats_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pimp_my_button/pimp_my_button.dart';

class XpChip extends StatelessWidget {
  const XpChip(
      {Key key,
      @required this.xp,
      this.showLevel = false,
      this.postFix = "XP",
      this.backgroundColor = Colors.deepOrange,
      this.avatarColor = Colors.deepOrangeAccent})
      : super(key: key);

  final int xp;
  final bool showLevel;
  final String postFix;
  final Color backgroundColor;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");

    return PimpedButton(
      pimpedWidgetBuilder: (context, controller) {
        controller.forward();
        return Chip(
          shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          label: Text(
            "${formatter.format(xp)} $postFix",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          avatar: showLevel
              ? CircleAvatar(
                  maxRadius: 100,
                  backgroundColor: avatarColor,
                  child: Text(
                    formatter.format(getLevel(xp)),
                    style: TextStyle(
                      color: Colors.grey.shade200,
                    ),
                  ),
                )
              : null,
          backgroundColor: backgroundColor,
        );
      },
      particle: DemoParticle(),
    );
  }
}
