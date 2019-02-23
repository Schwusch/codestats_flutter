import 'package:auto_size_text/auto_size_text.dart';
import 'package:codestats_flutter/widgets/shimmer.dart';
import 'package:flutter/material.dart';

class TotalXp extends StatelessWidget {
  const TotalXp({
    Key key,
    @required this.totalXp,
  }) : super(key: key);

  final int totalXp;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.blueGrey.shade600,
      highlightColor: Colors.blueGrey.shade100,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8),
        child: AutoSizeText(
          "${totalXp}",
          style: TextStyle(
            fontSize: 999,
            fontFamily: "OCRAEXT",
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(5.0, 5.0),
                blurRadius: 8.0,
                color: Color.fromARGB(125, 0, 0, 255),
              ),
            ],
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}