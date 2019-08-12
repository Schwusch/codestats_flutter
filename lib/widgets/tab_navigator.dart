import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:codestats_flutter/widgets/choose_user_menu.dart';
import 'package:codestats_flutter/widgets/dash_board_body.dart';
import 'package:codestats_flutter/widgets/reload_data.dart';
import 'package:codestats_flutter/widgets/settings.dart';
import 'package:flutter/material.dart';

class TabNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);

    var tabs = [
      Tab(text: "Profile"),
      Tab(text: "Recent"),
      Tab(text: "Languages"),
      Tab(text: "Year",)
    ];

    return DefaultTabController(
      child: BackdropScaffold(
        title: StreamBuilder(
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
        frontLayer: Container(
          child: DashBoardBody(
            bloc: bloc,
          ),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white,
                Colors.grey.shade100,
              ],
            ),
          ),
        ),
        backLayer: Settings(),
        iconPosition: BackdropIconPosition.leading,
        actions: [
          ReloadData(),
          ChooseUserMenu(),
        ],
      ),
      length: tabs.length,
    );
  }
}
