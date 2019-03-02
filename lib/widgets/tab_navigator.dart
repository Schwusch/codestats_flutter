import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:codestats_flutter/widgets/choose_user_menu.dart';
import 'package:codestats_flutter/widgets/dash_board_body.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:codestats_flutter/widgets/reload_data.dart';
import 'package:codestats_flutter/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

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
      bottomNavigationBar: StreamBuilder(
        stream: bloc.chosenTab.startWith(0),
        builder: (context, snapshot) => BubbleBottomBar(
              currentIndex: snapshot.data,
              opacity: .2,
              items: [
                BubbleBottomBarItem(
                  backgroundColor: Colors.red,
                  icon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  activeIcon: Icon(
                    Icons.person,
                    color: Colors.red,
                  ),
                  title: Text("Profile"),
                ),
                BubbleBottomBarItem(
                  backgroundColor: Colors.deepPurple,
                  icon: Icon(
                    Icons.timer,
                    color: Colors.black,
                  ),
                  activeIcon: Icon(
                    Icons.timer,
                    color: Colors.deepPurple,
                  ),
                  title: Text("Recent"),
                ),
                BubbleBottomBarItem(
                  backgroundColor: Colors.indigo,
                  icon: Icon(
                    Icons.translate,
                    color: Colors.black,
                  ),
                  activeIcon: Icon(
                    Icons.translate,
                    color: Colors.indigo
                  ),
                  title: Text("Languages"),
                ),
                BubbleBottomBarItem(
                  backgroundColor: Colors.green,
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.black,
                  ),
                  activeIcon: Icon(
                    Icons.calendar_today,
                    color: Colors.green
                  ),
                  title: Text("Year"),
                ),
              ],
              onTap: bloc.chosenTab.add,
            ),
      ),
      iconPosition: BackdropIconPosition.leading,
      actions: [
        ReloadData(),
        ChooseUserMenu(),
      ],
    );
  }
}
