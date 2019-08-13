import 'package:flutter/physics.dart';

class PassThroughSimulation extends Simulation {

  final double reverse;

  PassThroughSimulation({this.reverse = 0});

  @override
  double dx(double time) => (reverse - time).abs();

  @override
  bool isDone(double time) {
    if (reverse == 0) {
      return false;
    }
    return reverse - time < 0;
  }

  @override
  double x(double time) => (reverse - time).abs();
}