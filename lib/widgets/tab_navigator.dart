import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:codestats_flutter/widgets/choose_user_menu.dart';
import 'package:codestats_flutter/widgets/dash_board_body.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:codestats_flutter/widgets/reload_data.dart';
import 'package:codestats_flutter/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:flip_box_bar/flip_box_bar.dart';

class TabNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Attempt to hide keyboard, if shown
    FocusScope.of(context).requestFocus(FocusNode());
    UserBloc bloc = BlocProvider.of(context);

    return BackdropScaffold(
      title: StreamBuilder(
        stream: bloc.selectedUser,
        builder: (context, snapshot) => Text(snapshot.data ?? ""),
      ),
      frontLayer: Container(
        child: StreamBuilder(
          stream: bloc.dataFetching,
          initialData: DataFetching.Done,
          builder: (context, snapshot) {
            if (snapshot.data == DataFetching.Loading) {
              return Center(
                child: RandomLoadingAnimation(),
              );
            }

            return DashBoardBody();
          },
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
            backColor: Colors.green[300],
          ),
          FlipBarItem(
            icon: Icon(Icons.translate),
            text: Text(
              "Languages",
              style: TextStyle(color: Colors.black),
            ),
            frontColor: Colors.purple[700],
            backColor: Colors.purple[300],
          ),
          /*FlipBarItem(
              icon: Icon(Icons.calendar_today),
              text: Text("Year view"),
              frontColor: Colors.cyan.shade700,
              backColor: Colors.cyan.shade200,
            ),*/
        ],
        onIndexChanged: bloc.chosenTab.add,
      ),
      iconPosition: BackdropIconPosition.leading,
      actions: [
        ReloadData(),
        ChooseUserMenu(),
      ],
    );
  }
}
