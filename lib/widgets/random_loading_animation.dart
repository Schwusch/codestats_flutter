import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RandomLoadingAnimation extends StatelessWidget {
  final double size;
  final color;

  const RandomLoadingAnimation({
    Key key,
    this.size = 75,
    this.color = Colors.blueGrey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rand = Random();

    switch (rand.nextInt(17)) {
      case 0:
        return SpinKitHourGlass(
          color: color,
          size: size,
        );
      case 1:
        return SpinKitCircle(
          color: color,
          size: size,
        );
      case 2:
        return SpinKitCubeGrid(
          color: color,
          size: size,
        );
      case 3:
        return SpinKitDoubleBounce(
          color: color,
          size: size,
        );
      case 4:
        return SpinKitDualRing(
          color: color,
          size: size,
        );
      case 5:
        return SpinKitFadingCube(
          color: color,
          size: size,
        );
      case 6:
        return SpinKitRipple(
          color: color,
          size: size,
        );
      case 7:
        return SpinKitFadingGrid(
          color: color,
          size: size,
        );
      case 8:
        return SpinKitPulse(
          color: color,
          size: size,
        );
      case 9:
        return SpinKitPouringHourglass(
          color: color,
          size: size,
        );
      case 10:
        return SpinKitPumpingHeart(
          color: color,
          size: size,
        );
      case 11:
        return SpinKitFadingFour(
          color: color,
          size: size,
        );
      case 12:
        return SpinKitThreeBounce(
          color: color,
          size: size,
        );
      case 13:
        return SpinKitWave(
          color: color,
          size: size,
        );
      case 14:
        return SpinKitWanderingCubes(
          color: color,
          size: size,
        );
      case 15:
        return SpinKitRotatingPlain(
          color: color,
          size: size,
        );
      default:
        return SpinKitChasingDots(
          color: color,
          size: size,
        );
    }
  }
}
