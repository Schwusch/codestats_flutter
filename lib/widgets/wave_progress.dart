import 'dart:math';

import 'package:flutter/material.dart';

class WaveProgress extends StatefulWidget {
  final double size;
  final Color fillColor;
  final double progress;

  WaveProgress(this.size, this.fillColor, this.progress, {Key key})
      : super(key: key);

  @override
  WaveProgressState createState() => WaveProgressState();
}

class WaveProgressState extends State<WaveProgress>
    with TickerProviderStateMixin {
  AnimationController waveController;
  AnimationController heightController;
  Animation heightAnimation;
  Tween<double> heightTween;

  @override
  void initState() {
    super.initState();
    waveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    heightController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    heightAnimation = CurvedAnimation(
      parent: Tween(begin: 0.0, end: 1.0).animate(heightController),
      curve: Curves.easeOutCubic,
    );

    heightTween = Tween(begin: 0.0, end: widget.progress);

    heightController.forward(from: 0.0);
    waveController.repeat();
  }

  @override
  void dispose() {
    waveController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void update(double progress) {
    setState(() {
      heightTween = Tween(
        begin: heightTween.evaluate(heightController),
        end: progress,
      );
      heightController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      //decoration: new BoxDecoration(color: Colors.green),
      child: ClipPath(
        clipper: CircleClipper(),
        child: AnimatedBuilder(
          animation: waveController,
          builder: (BuildContext context, Widget child) {
            return CustomPaint(
              painter: WaveProgressPainter(
                heightTween.animate(heightAnimation),
                waveController,
                widget.fillColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

class WaveProgressPainter extends CustomPainter {
  Animation<double> _waveAnimation;
  Animation<double> _heightAnimation;
  Color fillColor;

  WaveProgressPainter(
    this._heightAnimation,
    this._waveAnimation,
    this.fillColor,
  ) : super(repaint: _waveAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // draw small wave
    Paint wave2Paint = Paint()..color = fillColor.withOpacity(0.5);
    double p = _heightAnimation.value;
    double n = 4.2;
    double amp = 4.0;
    double baseHeight = (1 - p) * size.height;

    Path path = Path();
    path.moveTo(0.0, baseHeight);
    for (double i = 0.0; i < size.width; i++) {
      path.lineTo(
          i,
          baseHeight +
              sin((i / size.width * 2 * pi * n) +
                      (_waveAnimation.value * 2 * pi) +
                      pi * 1) *
                  amp);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    canvas.drawPath(path, wave2Paint);

    // draw big wave
    Paint wave1Paint = Paint()..color = fillColor;
    n = 2.2;
    amp = 10.0;

    path = Path();
    path.moveTo(0.0, baseHeight);
    for (double i = 0.0; i < size.width; i++) {
      path.lineTo(
          i,
          baseHeight +
              sin((i / size.width * 2 * pi * n) +
                      (_waveAnimation.value * 2 * pi)) *
                  amp);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    canvas.drawPath(path, wave1Paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
