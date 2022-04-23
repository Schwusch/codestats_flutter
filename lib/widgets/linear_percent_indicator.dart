import 'package:flutter/material.dart';

enum LinearStrokeCap { butt, round, roundAll }

class LinearPercentIndicator extends StatefulWidget {
  ///Percent value between 0.0 and 1.0
  final double percent;
  final double? recent;
  final double width;

  ///Height of the line
  final double lineHeight;

  ///Color of the background of the Line , default = transparent
  final Color fillColor;

  ///First color applied to the complete line
  final Color backgroundColor;
  final Color recentColor;
  final Color progressColor;

  ///true if you want the Line to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the left of the Line
  final Widget? leading;

  ///widget at the right of the Line
  final Widget? trailing;

  ///widget inside the Line
  final Widget? center;

  ///The kind of finish to place on the end of lines drawn, values supported: butt, round, roundAll
  final LinearStrokeCap? linearStrokeCap;

  ///alignment of the Row (leading-widget-center-trailing)
  final MainAxisAlignment alignment;

  ///padding to the LinearPercentIndicator
  final EdgeInsets padding;

  LinearPercentIndicator(
      {Key? key,
      this.fillColor = Colors.transparent,
      this.percent = 0.0,
      this.lineHeight = 5.0,
      required this.width,
      this.backgroundColor = const Color(0xFFB8C7CB),
      this.progressColor = Colors.red,
      this.animation = false,
      this.animationDuration = 1000,
      this.leading,
      this.trailing,
      this.center,
      this.linearStrokeCap,
      this.padding = const EdgeInsets.symmetric(horizontal: 10.0),
      this.alignment = MainAxisAlignment.start,
      this.recentColor = Colors.green,
      this.recent = 0.0})
      : super(key: key) {
    if (percent < 0.0 || percent > 1.0) {
      throw Exception("Percent value must be a double between 0.0 and 1.0");
    }
  }

  @override
  _LinearPercentIndicatorState createState() => _LinearPercentIndicatorState();
}

class _LinearPercentIndicatorState extends State<LinearPercentIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  double _percent = 0.0;
  double _recent = 0.0;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDuration));
      _animation = CurvedAnimation(
        parent: Tween(begin: 0.0, end: 1.0).animate(
          _animationController!,
        ),
        curve: Curves.bounceOut,
      );
      _animationController!.forward();
    }

    _percent = widget.percent;
    _recent = widget.recent ?? 0;
    super.initState();
  }

  @override
  void didUpdateWidget(LinearPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent ||
        oldWidget.recent != widget.recent) {
      setState(() {
        _recent = widget.recent ?? 0;
        _percent = widget.percent;
        _animationController?.forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (widget.leading != null) {
      items.add(
          Padding(padding: EdgeInsets.only(right: 5.0), child: widget.leading));
    }
    items.add(Container(
        width: widget.width,
        height: widget.lineHeight * 2,
        padding: widget.padding,
        child: CustomPaint(
          painter: LinearPainter(
              animation: _animation,
              progress: _percent,
              recent: _recent,
              progressColor: widget.progressColor,
              recentColor: widget.recentColor,
              backgroundColor: widget.backgroundColor,
              linearStrokeCap: widget.linearStrokeCap,
              lineWidth: widget.lineHeight),
          child: (widget.center != null)
              ? Center(child: widget.center)
              : Container(),
        )));

    if (widget.trailing != null) {
      items.add(Padding(
          padding: const EdgeInsets.only(left: 5.0), child: widget.trailing));
    }

    return Material(
      color: Colors.transparent,
      child: Container(
          color: widget.fillColor,
          child: Row(
            mainAxisAlignment: widget.alignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: items,
          )),
    );
  }
}

class LinearPainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintRecentLine = Paint();
  final Paint _paintLine = Paint();
  final double lineWidth;
  final double? recent;
  final double progress;
  //final double center;
  final Color? recentColor;
  final Color progressColor;
  final Color backgroundColor;
  final LinearStrokeCap? linearStrokeCap;
  final Animation<double>? animation;

  LinearPainter({
    this.recent,
    this.recentColor,
    required this.lineWidth,
    required this.progress,
    //this.center,
    required this.progressColor,
    required this.backgroundColor,
    this.linearStrokeCap = LinearStrokeCap.butt,
    this.animation,
  }) : super(repaint: animation) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = lineWidth;

    _paintLine.color = progress.toString() == "0.0"
        ? progressColor.withOpacity(0.0)
        : progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;

    if (recent != null && recentColor != null) {
      _paintRecentLine.color = recent!.toString() == "0.0"
          ? recentColor!.withOpacity(0.0)
          : recentColor!;
      _paintRecentLine.style = PaintingStyle.stroke;
      _paintRecentLine.strokeWidth = lineWidth;
    }

    if (linearStrokeCap == LinearStrokeCap.round) {
      _paintLine.strokeCap = StrokeCap.round;
      _paintRecentLine.strokeCap = StrokeCap.round;
    } else if (linearStrokeCap == LinearStrokeCap.butt) {
      _paintLine.strokeCap = StrokeCap.butt;
      _paintRecentLine.strokeCap = StrokeCap.butt;
    } else {
      _paintLine.strokeCap = StrokeCap.round;
      _paintRecentLine.strokeCap = StrokeCap.round;
      _paintBackground.strokeCap = StrokeCap.round;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(0.0, size.height / 2);
    final end = Offset(size.width, size.height / 2);
    canvas.drawLine(start, end, _paintBackground);

    var _percent = progress * (animation?.value ?? 1);
    var _recent = (recent ?? 0) * (animation?.value ?? 1);

    canvas.drawLine(
        start,
        Offset(
          size.width * _recent,
          size.height / 2,
        ),
        _paintRecentLine);
    canvas.drawLine(
      start,
      Offset(
        size.width * _percent,
        size.height / 2,
      ),
      _paintLine,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
