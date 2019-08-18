import 'dart:ui';

import 'package:codestats_flutter/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';

class TiltableStack extends StatefulWidget {
  final List<Widget> children;
  final Alignment alignment;

  const TiltableStack({
    Key key,
    @required this.children,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  _TiltableStackState createState() => _TiltableStackState();
}

class _TiltableStackState extends State<TiltableStack>
    with TickerProviderStateMixin {
  AnimationController tilt;
  AnimationController depth;
  double pitch = 0;
  double yaw = 0;
  Offset _offset;
  SpringSimulation springSimulation;
  PublishSubject<bool> stream = PublishSubject();

  @override
  void initState() {
    super.initState();
    tilt = AnimationController(
      value: 1,
      duration: const Duration(milliseconds: 500),
      vsync: this,
      lowerBound: -2,
      upperBound: 2,
    )..addListener(() {
        if (_offset == null) {
          pitch *= tilt.value;
          yaw *= tilt.value;
          updateTransformation();
        }
      });
    depth = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 500),
      vsync: this,
      lowerBound: -2,
      upperBound: 2,
    )..addListener(updateTransformation);
  }

  @override
  dispose() {
    tilt.dispose();
    depth.dispose();
    stream.close();
    super.dispose();
  }

  updateTransformation() {
    stream.add(true);
  }

  SpringDescription spring = SpringDescription(mass: 1, stiffness: 400, damping: 6);

  cancelPan() {
    tilt.animateWith(SpringSimulation(spring, 1, 0, tilt.velocity));
    depth.animateWith(SpringSimulation(spring, depth.value, 0, depth.velocity));
    _offset = null;
  }

  startPan() {
    CodeStatsApp.platform.invokeMethod("startFourier");
    depth.animateWith(SpringSimulation(spring, depth.value, 1, depth.velocity));
  }

  updatePan(LongPressMoveUpdateDetails drag) {
    var size = MediaQuery.of(context).size;
    var offset = _globalToLocal(context, drag.globalPosition);
    if (_offset == null) {
      _offset = offset;
    }

    pitch += (offset.dy - _offset.dy) * (1 / size.height);
    yaw -= (offset.dx - _offset.dx) * (1 / size.width);
    _offset = offset;

    updateTransformation();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressMoveUpdate: updatePan,
      onLongPressStart: (_) => startPan(),
      onLongPressEnd: (_) => cancelPan(),
      onTapDown: (_) => depth.animateWith(SpringSimulation(spring, depth.value, 0, -5)),
      child: StreamBuilder<bool>(
        stream: stream.stream,
        builder: (context, snap) => TiltedStack(
          data: TransformationData(pitch, yaw, depth.value),
          alignment: widget.alignment,
          children: widget.children,
        ),
      ),
    );
  }

  Offset _globalToLocal(BuildContext context, Offset globalPosition) {
    final RenderBox box = context.findRenderObject();
    return box.globalToLocal(globalPosition);
  }
}

class TransformationData {
  final double pitch;
  final double yaw;
  final double depth;

  TransformationData(this.pitch, this.yaw, this.depth);
}

class TiltedStack extends StatelessWidget {
  const TiltedStack({
    Key key,
    @required this.children,
    @required this.alignment,
    @required this.data,
  }) : super(key: key);

  final TransformationData data;
  final List<Widget> children;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: alignment,
        children: children
            .asMap()
            .map(
              (i, element) {
                return MapEntry(
                  i,
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(data.pitch)
                          ..rotateY(data.yaw)
                          ..translate(
                              -data.yaw * i * 70, data.pitch * i * 70, 0)
                          ..scale((data.depth ?? 0) * (i + 1) * 0.1 + 1),
                        child: element,
                        alignment: FractionalOffset.center,
                      ),
                      if (element.key is ValueKey && (data.depth ?? 0) > 0)
                        Opacity(
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(data.pitch)
                              ..rotateY(data.yaw)
                              ..translate(-data.yaw * i * 1.5 * 70,
                                  data.pitch * i * 1.5 * 70, 0)
                              ..scale((data.depth ?? 0) * (i + 1) * 0.1 + 1),
                            child: children[i + 1],
                            alignment: FractionalOffset.center,
                          ),
                          opacity: 0.08,
                        ),
                    ],
                  ),
                );
              },
            )
            .values
            .toList(growable: false),
      );
}
