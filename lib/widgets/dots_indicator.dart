import 'dart:math';

import 'package:flutter/material.dart';

class DotsIndicator extends AnimatedWidget {
  const DotsIndicator({
    @required this.controller,
    @required this.itemCount,
    @required this.onPageSelected,
    this.color = Colors.white,
  })  : assert(controller != null),
        assert(itemCount != null),
        assert(onPageSelected != null),
        super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;
  final Color color;

  static const double _kDotSize = 6.0;
  static const double _kMaxZoom = 1.5;
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    final double page = controller.hasClients
        ? controller?.page ?? controller.initialPage.toDouble()
        : controller.initialPage.toDouble();
    final double correctedPage = page % itemCount;
    double selectedness;
    if (correctedPage > itemCount - 1 && index == 0) {
      selectedness =
          Curves.easeOut.transform(correctedPage - correctedPage.floor());
    } else {
      selectedness = Curves.easeOut
          .transform(max(0.0, 1.0 - (correctedPage - index).abs()));
    }
    final double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;

    final int pageForClicking = (page / itemCount).floor() * itemCount + index;

    return Container(
        width: _kDotSpacing,
        child: Center(
            child: Material(
              borderRadius: BorderRadius.circular(_kDotSize * zoom / 2),
              color: color,
              child: Container(
                  width: _kDotSize * zoom,
                  height: _kDotSize * zoom,
                  child: InkWell(onTap: () => onPageSelected(pageForClicking))),
            )));
  }

  Widget build(BuildContext context) {
    return Container(
      height:
      _kDotSize * 2, // put in fixed container to avoid "bouncing" on resize
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(itemCount, _buildDot),
      ),
    );
  }
}