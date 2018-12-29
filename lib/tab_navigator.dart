import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/widgets/fluid_slider.dart';
import 'package:codestats_flutter/widgets/language_levels.dart';
import 'package:codestats_flutter/widgets/profile_page.dart';
import 'package:codestats_flutter/widgets/week_xps.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flip_box_bar/flip_box_bar.dart';
import 'package:backdrop/backdrop.dart';

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
  AnimationController _controller;
  Animation animation;
  int recentLength = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);
    User userModel = widget.users[widget.currentUser];

    Widget body;

    if (userModel == null) {
      body = Center(
        child: CircularProgressIndicator(),
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

    _controller.forward(from: 0.0);

    return BackdropScaffold(
      title: Text(widget.currentUser ?? ""),
      frontLayer: Scaffold(
        body: FadeTransition(
          opacity: animation,
          child: Container(
            child: body,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade100,
                ],
              ),
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
      backLayer: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 30,
            left: 24,
            right: 24,
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Settings",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "Number of days in recent tab",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FluidSlider(
                  value: recentLength.toDouble(),
                  onChanged: (double newValue) {
                    setState(() {
                      recentLength = newValue.floor();
                    });
                  },
                  min: 1,
                  max: 14,
                  sliderColor: Colors.indigo,
                ),
              ),
            ],
          ),
        ),
      ),
      iconPosition: BackdropIconPosition.leading,
      actions: [
        PopupMenuButton(
          icon: Icon(Icons.people),
          onSelected: bloc.selectUser.add,
          itemBuilder: (BuildContext context) => widget.users.keys
              .map((user) => PopupMenuItem(
            value: user,
            child: Text(user),
          ))
              .toList(),
        )
      ],
    );
  }
}
