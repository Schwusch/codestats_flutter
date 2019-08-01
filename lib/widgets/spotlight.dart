import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/painting.dart';

import 'dots_indicator.dart';

class _SpotlightLayoutDelegate extends MultiChildLayoutDelegate {
  _SpotlightLayoutDelegate({
    @required this.page,
    @required this.itemCount,
  });

  final double page;
  final int itemCount;

  final double _z = 1.30;

  @override
  void performLayout(Size size) {
    final double offset = (page % itemCount) / itemCount;
    final Offset center = Offset(size.width / 2, size.height / 4);

    for (int i = 0; i < itemCount; i++) {
      final String childId = 'item$i';
      final double alpha = (i + offset * itemCount) * (2 * pi / itemCount);

      final double x = (1 - sin(alpha)) / 2;
      final double z = _z - (1 - cos(alpha)) / 2;

      if (hasChild(childId)) {
        final Size imageSize =
            layoutChild(childId, BoxConstraints.tight((size / 4) * z));

        positionChild(childId,
            Offset(size.width * x - (size.width / 8 * z), size.height / 6));
      }
    }
  }

  @override
  bool shouldRelayout(_SpotlightLayoutDelegate oldDelegate) =>
      page != oldDelegate.page || itemCount != oldDelegate.itemCount;
}

class Spotlight extends StatefulWidget {
  const Spotlight({
    Key key,
    @required this.children,
    @required this.titles,
    @required this.descriptions,
  })  : assert(children.length == descriptions.length),
        super(key: key);

  final List<Widget> children;
  final List<String> titles;
  final List<String> descriptions;

  @override
  _SpotlightState createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  final PageController _pageController = PageController(keepPage: false);
  static const Duration _kDuration = Duration(milliseconds: 300);
  static const Cubic _kCurve = Curves.ease;

  double _page = 0.0;
  int _pageIndex = 0;

  int get itemCount => widget.children.length;

  @override
  Widget build(BuildContext context) {
    final List<Widget> imagesWithId = <Widget>[];
    final List<Widget> renderLast = <Widget>[];
    // Paint order is determined by order of layout ids
    for (int i = 0; i < itemCount; i++) {
      final double offset = (_page % itemCount) / itemCount;
      final double alpha = (i + offset * itemCount) * (2 * pi / itemCount);
      // If in foreground, render last
      if (alpha % (2 * pi) < pi / 2 || alpha % (2 * pi) > 3 * pi / 2) {
        renderLast.add(LayoutId(
          id: 'item$i',
          child: widget.children[i],
        ));
        continue;
      }
      imagesWithId.add(LayoutId(
        id: 'item$i',
        child: widget.children[i],
      ));
    }
    imagesWithId.addAll(renderLast);
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0 &&
                notification is ScrollUpdateNotification) {
              final PageMetrics metrics = notification.metrics;
              if (metrics.page >= 0) {
                setState(() {
                  _page = metrics.page;
                  _pageIndex =
                      (itemCount - (_page % itemCount).round()) % itemCount;
                });
              }
            }
            return false;
          },
          child: Scrollable(
            dragStartBehavior: DragStartBehavior.start,
            axisDirection: AxisDirection.right,
            controller: _pageController,
            physics: const PageScrollPhysics(),
            viewportBuilder: (BuildContext context, ViewportOffset position) {
              return Viewport(
                offset: position,
                axisDirection: AxisDirection.right,
                slivers: <Widget>[
                  SliverFixedExtentList(
                    itemExtent: MediaQuery.of(context).size.width,
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return Container(
                        color: Colors.transparent,
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        CustomMultiChildLayout(
          children: imagesWithId,
          delegate: _SpotlightLayoutDelegate(
            itemCount: itemCount,
            page: _page,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(widget.titles[_pageIndex],
                    style: Theme.of(context).textTheme.headline),
                Text(
                  widget.descriptions[_pageIndex],
                  style: Theme.of(context)
                      .textTheme
                      .body2
                      .copyWith(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: DotsIndicator(
              controller: _pageController,
              itemCount: itemCount,
              color: CupertinoColors.inactiveGray,
              onPageSelected: (int page) {
                _pageController.animateToPage(
                  page,
                  duration: _kDuration,
                  curve: _kCurve,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
