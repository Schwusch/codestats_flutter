import 'package:flutter/material.dart';

class BreathingWidget extends StatefulWidget {
  final Widget child;

  const BreathingWidget({Key key, @required this.child}) : super(key: key);

  @override
  _BreathingWidgetState createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with TickerProviderStateMixin {
  AnimationController _breathingController;
  AnimationController _pulseController;
  Animation _animation;
  var _breathe = 0.0;

  @override
  void initState() {
    super.initState();
    _breathingController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _pulseController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _breathingController.forward();
      }
    });

    _animation = CurvedAnimation(
        parent: _breathingController,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn.flipped);

    _breathingController.addListener(() => setState(() {
          if (_breathingController.status == AnimationStatus.forward &&
              _animation.value > 0.3) {
            if (_pulseController.status != AnimationStatus.forward) {
              _pulseController.value = 0.0;
            }
            _pulseController.forward();
          }
          _breathe = _animation.value;
        }));

    _breathingController.forward();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PulsePainter(Curves.easeOut.transform(_pulseController.value)),
      child: Transform.scale(
        scale: 0.95 + (0.1 * _breathe),
        child: widget.child,
      ),
    );
  }
}

class PulsePainter extends CustomPainter {
  final double scale;

  PulsePainter(this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    var rect =
        Offset.zero.translate(-(size.width * 2.5), -5 - (size.height * 2.5)) &
            (size * 6);

    var dynamicColor = Colors.grey.withOpacity(
      1.0 - (scale * 0.2 + 0.85).clamp(0.0, 1.0),
    );

    var gradient = RadialGradient(
      colors: [
        Colors.transparent.withOpacity(0.0),
        dynamicColor,
        Colors.transparent.withOpacity(0.0),
        dynamicColor,
        Colors.transparent.withOpacity(0.0),
      ],
      stops: [
        scale,
        (scale + 0.05).clamp(0.0, 1.0),
        (scale + 0.07).clamp(0.0, 1.0),
        (scale + 0.10).clamp(0.0, 1.0),
        (scale + 0.2).clamp(0.0, 1.0),
      ],
    );

    canvas.drawRect(
        rect,
        Paint()
          ..shader = gradient.createShader(rect)
          ..blendMode = BlendMode.srcATop);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
