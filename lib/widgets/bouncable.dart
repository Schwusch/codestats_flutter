import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

typedef OnTap = void Function();

class Bouncable extends StatefulWidget {
  final Widget child;

  const Bouncable({Key key, this.child, this.onTap}) : super(key: key);
  final OnTap onTap;

  @override
  _BouncableState createState() => _BouncableState();
}

class _BouncableState extends State<Bouncable>
    with SingleTickerProviderStateMixin {
  AnimationController depth;
  SpringSimulation springSimulation;
  static SpringDescription spring =
  SpringDescription(mass: 1, stiffness: 400, damping: 6);

  @override
  void initState() {
    super.initState();
    depth = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 500),
      vsync: this,
      lowerBound: -2,
      upperBound: 2,
    );
  }

  @override
  void dispose() {
    depth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if(widget.onTap != null)
          widget.onTap();
        depth.animateWith(SpringSimulation(spring, depth.value, 0, -30));
      },
      child: AnimatedBuilder(
        animation: depth,
        builder: (_, __) =>
            Transform.scale(
              scale: depth.value * 0.1 + 1,
              child: widget.child,
            ),
      ),
    );
  }
}
