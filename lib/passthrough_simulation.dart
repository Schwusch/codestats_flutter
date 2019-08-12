import 'package:flutter/physics.dart';

class PassThroughSimulation extends Simulation {
  @override
  double dx(double time) => time;

  @override
  bool isDone(double time) => false;

  @override
  double x(double time) => time;
}