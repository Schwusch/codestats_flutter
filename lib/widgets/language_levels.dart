import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:codestats_flutter/widgets/level_percent_indicator.dart';
import 'package:collection/collection.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';

class LanguageLevelPage extends StatefulWidget {
  final User? userModel;

  const LanguageLevelPage({Key? key, this.userModel}) : super(key: key);

  @override
  _LanguageLevelPageState createState() => _LanguageLevelPageState();
}

class _LanguageLevelPageState extends State<LanguageLevelPage>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    widget.userModel?.totalLangs.sort((a, b) => b.xp - a.xp);
    Map<String, List<Xp>> recentLanguages =
        groupBy(widget.userModel!.recentLangs, (Xp element) => element.name);
    final userModel = widget.userModel!;
    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) =>
          DraggableScrollbar.arrows(
        backgroundColor: Colors.grey.shade500,
        padding: const EdgeInsets.only(right: 4.0),
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(top: 24, bottom: 24),
          itemCount: userModel.totalLangs.length,
          itemBuilder: (context, index) => LevelPercentIndicator(
            width: constraints.maxWidth * 0.7,
            name: userModel.totalLangs[index].name,
            xp: userModel.totalLangs[index].xp,
            recent: recentLanguages[userModel.totalLangs[index].name]
                ?.firstOrNull
                ?.xp,
          ),
        ),
        controller: scrollController,
      ),
    );
  }
}
