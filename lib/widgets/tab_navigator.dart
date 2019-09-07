import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:codestats_flutter/widgets/choose_user_menu.dart';
import 'package:codestats_flutter/widgets/dash_board_body.dart';
import 'package:codestats_flutter/widgets/glass_crack/glass_crack.dart';
import 'package:codestats_flutter/widgets/pulse_notification.dart';
import 'package:codestats_flutter/widgets/reload_data.dart';
import 'package:codestats_flutter/widgets/settings.dart';
import 'package:flutter/material.dart';

class TabNavigator extends StatefulWidget {
  final UserBloc bloc;

  TabNavigator({Key key, this.bloc}) : super(key: key);

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final tabs = [
    Tab(text: "Profile"),
    Tab(text: "Recent"),
    Tab(text: "Languages"),
    Tab(text: "Year")
  ];

  GlobalKey<BackdropScaffoldState> backdropKey = GlobalKey();
  bool breakGlass = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: WillPopScope(
        child: Stack(
          children: [
            PulseNotification(
              bloc: widget.bloc,
              child: BackdropScaffold(
                key: backdropKey,
                title: StreamBuilder(
                  stream: widget.bloc.selectedUser,
                  builder: (context, snapshot) => Text(snapshot.data ?? ""),
                ),
                appbarBottom: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BubbleTabIndicator(
                    indicatorHeight: 25.0,
                    indicatorColor: Colors.blueGrey.shade600,
                    tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  ),
                  tabs: tabs,
                ),
                frontLayer: Stack(
                  alignment: Alignment.center,
                  children: [
                    DashBoardBody(
                      bloc: widget.bloc,
                    ),
                  ],
                ),
                backLayer: Settings(),
                iconPosition: BackdropIconPosition.leading,
                actions: [
                  ReloadData(),
                  ChooseUserMenu(),
                ],
              ),
            ),
            if (breakGlass)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      breakGlass = false;
                    });
                  },
                  child: GlassCrack(),
                ),
              ),
          ],
        ),
        onWillPop: () async {
          if (breakGlass ||
              (backdropKey.currentState?.isBackPanelVisible ?? false)) {
            return true;
          }
          setState(() {
            breakGlass = true;
          });
          return false;
        },
      ),
    );
  }
}
