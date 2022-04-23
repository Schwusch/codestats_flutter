import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/utils.dart' show formatNumber, getLevel;
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class ExpandableUser {
  final String user;
  bool isExpanded = false;

  ExpandableUser({required this.user});

  Widget build(BuildContext context) {
    final bloc = context.read<UserBloc>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          color: Colors.white,
          icon: const Icon(
            Icons.share,
          ),
          onPressed: () => Share.share("https://codestats.net/users/$user"),
        ),
        IconButton(
          color: Colors.white,
          icon: const Icon(Icons.delete),
          onPressed: () {
            _showDialog(context, user, bloc);
          },
        )
      ],
    );
  }

  ExpansionPanelHeaderBuilder get headerBuilder =>
      (BuildContext context, bool isExpanded) {
        final bloc = context.read<UserBloc>();
        return ListTile(
          onTap: () {
            bloc.selectUser.add(user);
            Backdrop.of(context).fling();
          },
          title: Text(
            user,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            "${formatNumber(bloc.userStateController.value.allUsers[user]?.totalXp ?? 0)} XP",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          leading: CircleAvatar(
            child: Text(
                "${getLevel(bloc.userStateController.value.allUsers[user]?.totalXp ?? 0)}"),
          ),
        );
      };

  _showDialog(BuildContext context, String user, UserBloc bloc) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Remove $user?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                    onPressed: () {
                      bloc.removeUser(user);
                      Navigator.pop(context);
                    },
                    child: const Text("Ok"))
              ],
            ));
  }
}
