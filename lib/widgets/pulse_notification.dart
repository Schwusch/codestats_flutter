import 'dart:math';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:flutter/material.dart';

class PulseNotification extends StatefulWidget {
  const PulseNotification({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  final UserBloc bloc;

  @override
  _PulseNotificationState createState() => _PulseNotificationState();
}

class _PulseNotificationState extends State<PulseNotification>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.bloc.pulses,
      builder: (BuildContext context, AsyncSnapshot snap) {
        _controller.forward(from: 0.0);
        var animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticIn,
        );
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget child) => Transform.rotate(
            angle: -pi / 12,
            child: Transform.translate(
              child: Text(
                snap.hasData ? snap.data : "",
                style: TextStyle(

                    fontSize: 50,
                    fontFamily: 'OCRAEXT',
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    shadows: [Shadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                        offset: Offset(3.0, .0)
                    )]
                ),
              ),
              offset: Offset(animation.value * 500, 0.0),
            ),
          ),
        );
      },
    );
  }
}
