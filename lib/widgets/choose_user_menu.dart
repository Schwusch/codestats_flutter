import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:flutter/material.dart';

class ChooseUserMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);

    return StreamBuilder(
      stream: bloc.userStateController,
      builder: (context, AsyncSnapshot<UserState> snapshot) =>
          snapshot.hasData && snapshot.data.allUsers.isNotEmpty
              ? PopupMenuButton(
                  icon: Icon(Icons.people),
                  onSelected: (String user) {
                    Backdrop.of(context).showFrontLayer();
                    bloc.selectUser.add(user);
                  },
                  itemBuilder: (BuildContext context) =>
                      snapshot.data.allUsers.keys
                          .map((user) => PopupMenuItem(
                                value: user,
                                child: Text(user),
                              ))
                          .toList(),
                )
              : Container(),
    );
  }
}
