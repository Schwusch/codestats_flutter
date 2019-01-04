import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SubHeader extends StatelessWidget {
  const SubHeader({
    Key key,
    @required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
      child: Center(
        child: AutoSizeText(
          text,
          maxLines: 1,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            fontFamily: 'OCRAEXT',
            shadows: [
              Shadow(
                offset: Offset(2.5, 2.5),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}