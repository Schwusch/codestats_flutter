import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseUserMenu extends StatelessWidget {
  const ChooseUserMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserBloc>();

    return StreamBuilder(
      stream: bloc.userStateController,
      builder: (context, AsyncSnapshot<UserState> snapshot) =>
          snapshot.hasData && snapshot.data!.allUsers.isNotEmpty
              ? PopupMenuButton(
                  icon: const Icon(Icons.people),
                  onSelected: (String user) {
                    Backdrop.of(context).showFrontLayer();
                    bloc.selectUser.add(user);
                  },
                  itemBuilder: (BuildContext context) =>
                      snapshot.data!.allUsers.keys
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
