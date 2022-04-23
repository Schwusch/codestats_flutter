import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:codestats_flutter/widgets/choose_user_menu.dart';
import 'package:codestats_flutter/widgets/dash_board_body.dart';
import 'package:codestats_flutter/widgets/reload_data.dart';
import 'package:codestats_flutter/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TabNavigator extends StatefulWidget {
  const TabNavigator({Key? key}) : super(key: key);

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final tabs = [
    const Tab(text: "Profile"),
    const Tab(text: "Recent"),
    const Tab(text: "Languages"),
    const Tab(text: "Year")
  ];

  GlobalKey<BackdropScaffoldState> backdropKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserBloc>();
    return DefaultTabController(
      length: tabs.length,
      child: BackdropScaffold(
        key: backdropKey,
        title: StreamBuilder<String>(
          stream: bloc.selectedUser,
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
              bloc: bloc,
            ),
          ],
        ),
        backLayer: Settings(),
        iconPosition: BackdropIconPosition.leading,
        actions: [
          ReloadData(),
          const ChooseUserMenu(),
        ],
      ),
    );
  }
}
