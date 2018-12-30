import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:codestats_flutter/widgets/choose_user_menu.dart';
import 'package:codestats_flutter/widgets/language_levels.dart';
import 'package:codestats_flutter/widgets/profile_page.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:codestats_flutter/widgets/reload_data.dart';
import 'package:codestats_flutter/widgets/settings.dart';
import 'package:codestats_flutter/widgets/week_xps.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flip_box_bar/flip_box_bar.dart';

class TabNavigator extends StatefulWidget {
  final Map<String, charts.Color> colors;
  final Map<String, User> users;
  final String currentUser;

  TabNavigator({
    @required this.colors,
    @required this.users,
    @required this.currentUser,
  });

  @override
  TabNavigatorState createState() {
    return new TabNavigatorState();
  }
}

class TabNavigatorState extends State<TabNavigator>
    with SingleTickerProviderStateMixin {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);
    User userModel = widget.users[widget.currentUser];

    Widget body;

    if (widget.currentUser != null &&
        widget.currentUser.isNotEmpty &&
        userModel == null) {
      body = Center(
        child: RandomLoadingAnimation(),
      );
    } else if (widget.currentUser == null || widget.currentUser.isEmpty) {
      if (widget.users.isNotEmpty) {
        bloc.selectUser.add(widget.users.keys.first);
      }
      body = Center(
        child: Text("No user chosen"),
      );
    } else {
      switch (tabIndex) {
        case 0:
          body = ProfilePage(
            userModel: userModel,
            bloc: bloc,
            userName: widget.currentUser,
          );
          break;
        case 1:
          body = WeekStatistics(
            userModel: userModel,
            colors: widget.colors,
          );
          break;
        case 2:
          body = LanguageLevelPage(
            userModel: userModel,
          );
          break;
        case 3:
          // TODO Year view
          break;
      }
    }

    return BackdropScaffold(
      title: Text(widget.currentUser ?? ""),
      frontLayer: Scaffold(
        body: Container(
          child: StreamBuilder(
              stream: bloc.dataFetching,
              initialData: DataFetching.Done,
              builder: (context, snapshot) {
                if (snapshot.data == DataFetching.Loading) {
                  return Center(
                    child: RandomLoadingAnimation(),
                  );
                }

                return body;
              }),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white,
                Colors.grey.shade100,
              ],
            ),
          ),
        ),
        bottomNavigationBar: FlipBoxBar(
          animationDuration: Duration(milliseconds: 500),
          items: [
            FlipBarItem(
              icon: Icon(Icons.person),
              text: Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
              frontColor: Colors.amber[700],
              backColor: Colors.amber[300],
            ),
            FlipBarItem(
                icon: Icon(Icons.timer),
                text: Text(
                  "Recent",
                  style: TextStyle(color: Colors.black),
                ),
                frontColor: Colors.green[800],
                backColor: Colors.green[300]),
            FlipBarItem(
                icon: Icon(Icons.translate),
                text: Text(
                  "Languages",
                  style: TextStyle(color: Colors.black),
                ),
                frontColor: Colors.purple[700],
                backColor: Colors.purple[300]),
            /*FlipBarItem(
              icon: Icon(Icons.calendar_today),
              text: Text("Year view"),
              frontColor: Colors.cyan.shade700,
              backColor: Colors.cyan.shade200,
            ),*/
          ],
          onIndexChanged: (newIndex) => setState(() {
                tabIndex = newIndex;
              }),
        ),
      ),
      backLayer: Settings(
        bloc: bloc,
        users: widget.users,
      ),
      iconPosition: BackdropIconPosition.leading,
      actions: [
        ReloadData(bloc: bloc),
        ChooseUserMenu(bloc: bloc, widget: widget)
      ],
    );
  }
}
