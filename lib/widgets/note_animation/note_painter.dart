import 'dart:math';

import 'package:flutter/material.dart';

class NotePainter extends CustomPainter {
  Color lineColor;
  double width;
  double note;
  double height;
  static const angleOffset = pi / 20;
  NotePainter({
    this.lineColor = Colors.blue,
    this.width = 1,
    this.note = 0,
    this.height = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);

    drawHump(radius, (pi / 12) * note - pi / 2, line, canvas, Colors.amber);
    drawHump(radius, -(pi / 12) * note - pi / 2, line, canvas, Colors.amber);
  }

  void drawHump(double radius, double theta, Paint line, Canvas canvas, Color color) {
    Path path = Path();

    path.moveTo(
      radius * cos(theta - angleOffset) + radius,
      radius * sin(theta - angleOffset) + radius,
    );
    path.quadraticBezierTo(
      (radius + radius * 0.02 * height) * cos(theta - angleOffset / 2) + radius,
      (radius + radius * 0.02 * height) * sin(theta - angleOffset / 2) + radius,
      (radius + radius * 0.05 * height) * cos(theta - angleOffset / 2.5) + radius,
      (radius + radius * 0.05 * height) * sin(theta - angleOffset / 2.5) + radius,
    );

    path.quadraticBezierTo(
      (radius + radius * 0.2 * height) * cos(theta) + radius,
      (radius + radius * 0.2 * height) * sin(theta) + radius,
      (radius + radius * 0.05 * height) * cos(theta + angleOffset / 2.5) +
          radius,
      (radius + radius * 0.05 * height) * sin(theta + angleOffset / 2.5) +
          radius,
    );
    path.quadraticBezierTo(
        (radius + radius * 0.02 * height) * cos(theta + angleOffset / 2) +
            radius,
        (radius + radius * 0.02 * height) * sin(theta + angleOffset / 2) +
            radius,
        radius * cos(theta + angleOffset) + radius,
        radius * sin(theta + angleOffset) + radius);

    path.close();

    line.color = color;

    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
