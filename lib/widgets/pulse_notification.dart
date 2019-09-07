import 'dart:math';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class PulseNotification extends StatefulWidget {
  const PulseNotification({
    Key key,
    @required this.bloc,
    this.child,
  }) : super(key: key);

  final UserBloc bloc;
  final Widget child;

  @override
  _PulseNotificationState createState() => _PulseNotificationState();
}

class _PulseNotificationState extends State<PulseNotification>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    );
    super.initState();
  }

  ConfettiController confettiController = ConfettiController(
    duration: Duration(seconds: 1),
  );

  @override
  void dispose() {
    confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String message;
    return StreamBuilder(
      stream: widget.bloc.pulses,
      builder:
          (BuildContext context, AsyncSnapshot<OnlyOnceData<String>> snap) {
        if (snap.hasData && !snap.data.used) {
          confettiController.play();
          _controller.forward(from: 0.0);
          message = snap.data.value;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget child) =>
                  Transform.rotate(
                angle: -pi / 12,
                child: Transform.translate(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      message ?? "",
                      style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'OCRAEXT',
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        shadows: [
                          Shadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                              offset: Offset(3.0, .0)),
                        ],
                      ),
                    ),
                  ),
                  offset: Offset(animation.value * 500, 0.0),
                ),
              ),
            ),
            ConfettiWidget(
              confettiController: confettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 5,
              shouldLoop: false,
            )
          ],
        );
      },
    );
  }
}
