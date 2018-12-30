import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/tab_navigator.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:flutter/material.dart';

class ChooseUserMenu extends StatelessWidget {
  const ChooseUserMenu({
    Key key,
    @required this.bloc,
    @required this.widget,
  }) : super(key: key);

  final UserBloc bloc;
  final TabNavigator widget;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.people),
      onSelected: (user) {
        Backdrop.of(context).showFrontLayer();
        bloc.selectUser.add(user);
      },
      itemBuilder: (BuildContext context) => widget.users.keys
          .map((user) => PopupMenuItem(
                value: user,
                child: Text(user),
              ))
          .toList(),
    );
  }
}
