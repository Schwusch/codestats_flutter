import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TiltableStack extends StatefulWidget {
  final List<Widget> children;
  final Alignment alignment;

  const TiltableStack({
    Key key,
    this.children,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  _TiltableStackState createState() => _TiltableStackState();
}

class _TiltableStackState extends State<TiltableStack>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> tilt;
  Animation<double> depth;
  double pitch = 0;
  double yaw = 0;
  Offset _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addListener(() {
        setState(() {
          if (tilt != null) {
            pitch *= tilt.value;
            yaw *= tilt.value;
          }
        });
      })
      ..forward(from: 1.0);
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
  }

  cancelPan() {
    tilt = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn.flipped,
      ),
    );
    depth = tilt;
    _controller.forward();
    _offset = null;
  }

  startPan() {
    tilt = null;
    depth = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(1.0, 0.0, 1.0, 1.0),
      ),
    );
    _controller.reverse();
  }

  updatePan(LongPressMoveUpdateDetails drag) {
    setState(() {
      var size = MediaQuery.of(context).size;
      var offset = _globalToLocal(context, drag.globalPosition);
      if(_offset == null) {
        _offset = offset;
      }

      pitch += (offset.dy - _offset.dy) * (1 / size.height);
      yaw -= (offset.dx - _offset.dx) * (1 / size.width);
      _offset = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onLongPressMoveUpdate: updatePan,
      onLongPressStart: (_) => startPan(),
      onLongPressEnd: (_) => cancelPan(),
      child: Stack(
        alignment: widget.alignment,
        children: widget.children
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
                          ..rotateX(pitch)
                          ..rotateY(yaw)
                          ..translate(-yaw * i * 70, pitch * i * 70, 0)
                          ..scale((depth?.value ?? 0) * (i + 1) * 0.1 + 1),
                        child: element,
                        alignment: FractionalOffset.center,
                      ),
                      if (i == 1 && (depth?.value ?? 0) > 0)
                        Opacity(
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(pitch)
                              ..rotateY(yaw)
                              ..translate(
                                  -yaw * i * 1.5 * 70, pitch * i * 1.5 * 70, 0)
                              ..scale((depth?.value ?? 0) * (i + 1) * 0.1 + 1),
                            child: widget.children[i + 1],
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
            .toList(),
      ),
    );
  }

  Offset _globalToLocal(BuildContext context, Offset globalPosition) {
    final RenderBox box = context.findRenderObject();
    return box.globalToLocal(globalPosition);
  }
}
