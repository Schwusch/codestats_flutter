import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:superpower/superpower.dart';

class GlassCrack extends StatelessWidget {
  final Widget child;

  const GlassCrack({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              ClipRect(
            child: CustomPaint(
              isComplex: true,
              willChange: false,
              child: child,
              size: child == null
                  ? Size(constraints.maxWidth, constraints.maxHeight)
                  : Size.zero,
              painter: GlassCrackPainter(),
            ),
          ),
        ),
      );
}

class Line {
  final Offset p1;
  final Offset p2;
  final PathDescription desc;
  final int level;
  final double opacity;

  Line(this.p1, this.p2, this.level, this.desc, this.opacity);
}

class _Point {
  final int angle;
  final Offset point;

  _Point(this.angle, this.point);
}

class PathDescription {
  static Random _random = Random();
  Offset delta;
  double deltaLength;

  // Vectors
  Offset vectorS;
  Offset vectorT;

  // Curvature
  double mpp;
  double mpl1;
  double mpl2;
  double ll;
  double cma;
  Offset cpt;
  Rectangle<double> boundingBox;

  PathDescription(Offset p1, Offset p2, double cv) {
    delta = p2 - p1;
    deltaLength = delta.distance;

    vectorS = delta / deltaLength;
    vectorT = Offset(delta.dy / deltaLength, -delta.dx / deltaLength);

    mpp = _random.nextDouble() * 0.5 + 0.3;
    mpl1 = deltaLength * mpp;
    mpl2 = deltaLength - mpl1;

    ll = log(deltaLength * e);
    cma = _random.nextDouble() * ll * cv - ll * cv / 2;
    cpt = Offset(p1.dx + vectorS.dx * mpl1 + vectorT.dx * cma,
        p1.dy + vectorS.dy * mpl1 + vectorT.dy * cma);
    var bbx1 = min(min(p1.dx, p2.dx), cpt.dx);
    var bby1 = min(min(p1.dy, p2.dy), cpt.dy);
    var bbx2 = max(max(p1.dx, p2.dx), cpt.dx);
    var bby2 = max(max(p1.dy, p2.dy), cpt.dy);
    boundingBox = Rectangle.fromPoints(Point(bbx1, bby1), Point(bbx2, bby2));
  }
}

class PaintPathPair {
  final Paint paint;
  final Path path;

  PaintPathPair(this.paint, this.path);
}

class GlassCrackPainter extends CustomPainter {
  static const ns = 0.03;
  static const st = 0.14;
  static const hl = 0.2;
  static const freq = 0.2;
  static var random = Random();
  List<Line> lines;
  Map<Line, PaintPathPair> reflectCache = Map();
  Map<Line, List<PaintPathPair>> fractureCache = Map();
  Map<Line, PaintPathPair> mainCache = Map();
  Map<Line, List<PaintPathPair>> noiseCache = Map();

  @override
  void paint(Canvas canvas, Size size) {
    lines ??= findCrackEffectPaths(size);
    canvas.drawColor(Colors.black.withOpacity(0.1), BlendMode.srcOver);
    renderLcdArtifacts(canvas, size);
    for (var line in lines) {
      renderCrackEffectReflect(canvas, line);
      renderCrackEffectFractures(canvas, line);
      renderCrackEffectMainLine(canvas, line);
      renderCrackEffectNoise(canvas, line);
    }
  }

  void renderLcdArtifacts(Canvas canvas, Size size) {
    var gradients = [
      LinearGradient(
        colors: [
          Colors.purpleAccent.shade100.withOpacity(0.8),
          Colors.purpleAccent.shade100,
          Colors.purpleAccent.shade100.withOpacity(0.8)
        ],
        stops: [0, 0.5, 1],
      ),
      LinearGradient(
        colors: [
          Colors.greenAccent.shade100.withOpacity(0.8),
          Colors.greenAccent.shade100,
          Colors.greenAccent.shade100.withOpacity(0.8),
        ],
        stops: [0, 0.5, 1],
      )
    ];
    
    for (Gradient gradient in gradients) {
      var xpos = random.nextDouble();
      var start = Offset(size.width * xpos, 0);
      var stop = Offset(size.width * xpos, size.height);
      var paint = Paint()
        ..color = Colors.purple
        ..strokeWidth = 10
        ..shader = gradient.createShader(
            Rect.fromPoints(start.translate(-5, 0), stop.translate(5, 0)));
      canvas.drawLine(start, stop, paint);
    };
  }

  void renderCrackEffectReflect(Canvas canvas, Line line) {
    if (reflectCache[line] == null) {
      var gradient = LinearGradient(colors: [
        Colors.white.withOpacity(0),
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0)
      ], stops: [
        0,
        0.5,
        1
      ]);
      var dd = line.desc.deltaLength / 3;
      var tx = line.desc.vectorT.dx;
      var ty = line.desc.vectorT.dy;
      var ddtx = dd * tx;
      var ddty = dd * ty;

      var paint = Paint();
      try {
        paint.shader = gradient.createShader(
          Rect.fromPoints(
            Offset(line.p1.dx + ddtx, line.p1.dy + ddty),
            Offset(line.p1.dx - ddtx, line.p1.dy - ddty),
          ),
        );
      } catch (e) {
        print(e);
      }
      var path = Path()
        ..moveTo(line.p1.dx + ddtx, line.p1.dy + ddty)
        ..lineTo(line.p2.dx + ddtx, line.p2.dy + ddtx)
        ..lineTo(line.p2.dx - ddtx, line.p2.dy - ddty)
        ..lineTo(line.p1.dx - ddtx, line.p1.dy - ddty)
        ..close();

      reflectCache[line] = PaintPathPair(paint, path);
    }
    var foo = reflectCache[line];
    canvas.drawPath(foo.path, foo.paint);
  }

  renderCrackEffectFractures(Canvas canvas, Line line) {
    if (fractureCache[line] == null) {
      List<PaintPathPair> cacheList = [];
      var dl = line.desc.deltaLength;
      var mp = dl / 10;
      var cma = line.desc.cma;
      var mpl1 = line.desc.mpl1;
      var mpl2 = line.desc.mpl2;
      var mpp = line.desc.mpp;
      var tx = line.desc.vectorT.dx;
      var ty = line.desc.vectorT.dy;
      var sx = line.desc.vectorS.dx;
      var sy = line.desc.vectorS.dy;
      var sz = 33;

      for (var s = 0.0; s < dl; s = s + 16) {
        var c;
        if (s < mpp * dl) {
          c = cma * (1 - pow((mpl1 - s) / mpl1, 2));
        } else {
          c = cma * (1 - pow((mpl2 - dl + s) / mpl2, 2));
        }

        c /= 2;

        var p = pow((s > mp ? dl - s : s) / mp, 2);

        var w = random.nextDouble() + 1;
        var h1 = sz - random.nextDouble() * p * sz + 1;
        var h2 = sz - random.nextDouble() * p * sz + 1;
        var t = random.nextDouble() * 20 - 10;

        if (random.nextDouble() > p - sz / mp) {
          var paint = Paint()
            ..color = Colors.white
                .withOpacity((random.nextDouble() * 8 + 4).round() / 12);
          var path = Path()
            ..moveTo(line.p1.dx + s * sx + c * tx, line.p1.dy + s * sy + c * ty)
            ..lineTo(line.p1.dx + (t + s + w / 2) * sx + h1 * tx + c * tx,
                line.p1.dy + (-t + s + w / 2) * sy + h1 * ty + c * ty)
            ..lineTo(line.p1.dx + (s + w) * sx + c * tx,
                line.p1.dy + (s + w) * sy + c * ty)
            ..lineTo(line.p1.dx + (-t + s + w / 2) * sx - h2 * tx + c * tx,
                line.p1.dy + (t + s + w / 2) * sy - h2 * ty + c * ty)
            ..close();
          cacheList.add(PaintPathPair(paint, path));
        }
        s += mp * (p / 2 + 0.5);
      }
      fractureCache[line] = cacheList;
    }
    fractureCache[line]
        .forEach((pair) => canvas.drawPath(pair.path, pair.paint));
  }

  renderCrackEffectMainLine(Canvas canvas, Line line) {
    if (mainCache[line] == null) {
      var cpt = line.desc.cpt;
      double tt = random.nextDouble() * ns * 2 - ns;
      Paint paint = Paint()
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(line.opacity);
      Path path = Path()
        ..moveTo(line.p1.dx, line.p1.dy)
        ..quadraticBezierTo(
            cpt.dx,
            cpt.dy,
            line.p2.dx + (st - tt) * line.desc.vectorT.dx,
            line.p2.dy + (st + tt) * line.desc.vectorT.dy);
      mainCache[line] = PaintPathPair(paint, path);
    }

    var foo = mainCache[line];
    canvas.drawPath(foo.path, foo.paint);
  }

  renderCrackEffectNoise(Canvas canvas, Line line) {
    if (noiseCache[line] == null) {
      List<PaintPathPair> cacheList = [];
      var dl = line.desc.deltaLength;
      var dd = dl / 2;
      var cma = line.desc.cma;
      var mpl1 = line.desc.mpl1;
      var mpl2 = line.desc.mpl2;
      var tx = line.desc.vectorT.dx;
      var ty = line.desc.vectorT.dy;
      var sx = line.desc.vectorS.dx;
      var sy = line.desc.vectorS.dy;

      int step = (dd * (1 - (freq + 0.5) / 1.5) + 1).ceil();
      var c;
      for (var s = 0.0; s < dl; s = s + 3) {
        if (s < line.desc.mpp * dl) {
          c = cma * (1 - pow((mpl1 - s) / mpl1, 2));
        } else {
          c = cma * (1 - pow((mpl2 - dl + s) / mpl2, 2));
        }
        c /= 2;

        for (var t = -dd; t < dd; t = t + 2) {
          if (random.nextDouble() > t.abs() / dd) {
            var cnt = (random.nextDouble() * 2 + 0.5).floor();
            var m = random.nextDouble() * 2 - 1;
            while (cnt >= 0) {
              Paint paint = Paint()
                ..strokeWidth = 1
                ..style = PaintingStyle.stroke
                ..color = Colors.white
                    .withOpacity((random.nextDouble() * 10 + 2).round() / 30);
              var pos = (random.nextDouble() * 5 + 0.5);
              var path = Path()
                ..moveTo(line.p1.dx + (s - pos) * sx + (m + t) * tx + c * tx,
                    line.p1.dy + (s - pos) * sy + (-m + t) * ty + c * ty)
                ..lineTo(line.p1.dx + (s + pos) * sx + (-m + t) * tx + c * tx,
                    line.p1.dy + (s + pos) * sy + (m + t) * ty + c * ty);
              cacheList.add(PaintPathPair(paint, path));
              cnt--;
            }
          }
          t += random.nextDouble() * step * 2;
        }
        s += random.nextDouble() * step * 4;
      }
      noiseCache[line] = cacheList;
    }
    noiseCache[line].forEach((pair) => canvas.drawPath(pair.path, pair.paint));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  List<Line> findCrackEffectPaths(Size size) {
    var imw = size.width;
    var imh = size.height;
    var c = Offset(imw / 2, imh / 2);
    $List<$List<_Point>> points = $List()..add($List());
    List<Line> lines = [];
    var level = 1;
    var r = 15.0;
    var num = 20;
    int ang = 360 ~/ (num + 1);
    int maxLevel = 0;
    /*
     * Part 1: Create a table of points that we can use to draw crack segments
     * between.  First, we need to find the number of lines that will run
     * outward from the center of the crack.  Each of these lines will be
     * staggered at various angles.  The points will be placed on these
     * lines at different intervals defined by the concentric circles
     * created by incrementing the starting radius.
     */

    while (points[0].length < num) {
      var angle = ((ang * points[0].length) + 10);
      Offset point = findPointOnCircle(c, 5, angle);
      points[0].add(_Point(angle, point));
    }

    while (r < 500) {
      $List<_Point> levelPoints = $List();
      for (var num2 = 0; num2 < num; num2++) {
        var point1 = points.elementAtOrNull(level - 1)?.elementAtOrNull(num2);

        if (point1 != null &&
            point1.point.dx > 0 &&
            point1.point.dx < imw &&
            point1.point.dy > 0 &&
            point1.point.dy < imh) {
          ang = (point1.angle + random.nextDouble() * 10 / num - 10 / 2 / num)
              .toInt()
              .clamp(0, 350);

          var point2 = findPointOnCircle(
              c,
              (r + random.nextDouble() * r / level - r / (level * 2)).toInt(),
              ang);
          levelPoints.add(_Point(ang, point2));
        } else if (maxLevel == 0) {
          maxLevel = level;
        }
      }

      points.add(levelPoints);

      level++;
      r *= random.nextDouble() * 1.5 + 1;
    }

    /*
     * Part 2: Find the actual cracked lines between the points.
     * There are three lines that can be drawn:
     *
     *   a) The original lines from the center radiating out to the
     *      edges.  These are always drawn
     *   b) Lines connecting two adjacent points on the same circle
     *   c) Lines connecting two adjacent points on different circles
     *
     *   b & c are only drawn based a on random interval.  These
     *   lines create the web effect of the cracking.
     */

    if (maxLevel == 0) maxLevel = level;

    var l = 1, g = 0;

    for (; l < level; l++) {
      for (g = 0; g < num; g++) {
        var point1 = points.elementAtOrNull(l - 1)?.elementAtOrNull(g);
        var point2 = points.elementAtOrNull(l)?.elementAtOrNull(g);

        if (point1 != null && point2 != null) {
          lines.add(Line(
            point1.point,
            point2.point,
            l,
            PathDescription(point1.point, point2.point, 0.3),
            (random.nextDouble() * 8 + 4) / 12,
          ));
          var tryIndex = (g + 1) % num;
          if (random.nextDouble() < 0.6) {
            if (points[l].length > tryIndex) {
              point1 = points[l][tryIndex];
              lines.add(Line(
                  point2.point,
                  point1.point,
                  l,
                  PathDescription(point2.point, point1.point, 0.3),
                  (random.nextDouble() * 8 + 4) / 12));
            }
          }
          if (l < level - 1 && random.nextDouble() < 0.3) {
            if (points[l + 1].length > tryIndex) {
              point1 = points[l + 1][tryIndex];
              lines.add(Line(
                  point2.point,
                  point1.point,
                  l,
                  PathDescription(point2.point, point1.point, 0.3),
                  (random.nextDouble() * 8 + 4) / 12));
            }
          }
        }
      }
    }
    return lines;
  }

  static const _RAD = pi / 180;

  Offset findPointOnCircle(Offset center, int radius, int angle) => Offset(
        center.dx + radius * cos(angle * _RAD) - radius * sin(angle * _RAD),
        center.dy + radius * sin(angle * _RAD) + radius * cos(angle * _RAD),
      );
}
