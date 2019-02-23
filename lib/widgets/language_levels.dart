import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:codestats_flutter/sequence_animation.dart';
import 'package:codestats_flutter/widgets/level_percent_indicator.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:superpower/superpower.dart';

class LanguageLevelPage extends StatefulWidget {
  final User userModel;

  const LanguageLevelPage({Key key, @required this.userModel})
      : super(key: key);

  @override
  _LanguageLevelPageState createState() => _LanguageLevelPageState();
}

class _LanguageLevelPageState extends State<LanguageLevelPage>
    with TickerProviderStateMixin {
  SequenceAnimation sequence;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    final builder = SequenceAnimationBuilder();
    final offsetTween = Tween<Offset>(
      begin: Offset(0.0, 20.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.fastOutSlowIn));

    $(widget.userModel.totalLangs).forEachIndexed((_, index) {
      builder.addAnimatable(
        animatable: offsetTween,
        from: Duration(milliseconds: 50 * index),
        to: Duration(milliseconds: 50 * index + 400),
        tag: "$index",
      );
    });

    sequence = builder.animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.userModel.totalLangs.sort((a, b) => b.xp - a.xp);
    Map<String, List<Xp>> recentLanguages =
        groupBy(widget.userModel.recentLangs, (Xp element) => element.name);

    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) => ListView.builder(
            padding: EdgeInsets.only(top: 24, bottom: 24),
            itemCount: widget.userModel.totalLangs.length,
            itemBuilder: (context, index) => SlideTransition(
              position: sequence["$index"],
              child: LevelPercentIndicator(
                width: constraints.maxWidth * 0.7,
                name: widget.userModel.totalLangs[index].name,
                xp: widget.userModel.totalLangs[index].xp,
                recent:
                recentLanguages[widget.userModel.totalLangs[index].name]
                    ?.first
                    ?.xp,
              ),
            ),
          ),
    );
  }
}
