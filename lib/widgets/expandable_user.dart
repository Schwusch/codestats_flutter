import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/utils.dart' show formatNumber, getLevel;
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:flutter/material.dart';
//import 'package:share/share.dart';

class ExpandableUser {
  final String user;
  bool isExpanded = false;

  ExpandableUser({@required this.user});

  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        /*IconButton(
          color: Colors.white,
          icon: Icon(
            Icons.share,
          ),
          onPressed: () => Share.share("https://codestats.net/users/$user"),
        ),*/
        IconButton(
          color: Colors.white,
          icon: Icon(Icons.delete),
          onPressed: () {
            _showDialog(context, user, bloc);
          },
        )
      ],
    );
  }

  ExpansionPanelHeaderBuilder get headerBuilder =>
          (BuildContext context, bool isExpanded) {
        UserBloc bloc = BlocProvider.of(context);
        return ListTile(
          onTap: () {
            bloc.selectUser.add(user);
            Backdrop.of(context).fling();
          },
          title: Text(
            user,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            "${formatNumber(bloc.userStateController.value.allUsers[user]?.totalXp ?? 0)} XP",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: CircleAvatar(
            child: Text(
                "${getLevel(
                    bloc.userStateController.value.allUsers[user]?.totalXp ??
                        0)}"),
          ),
        );
      };

  _showDialog(BuildContext context, String user, UserBloc bloc) {
    showDialog(context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Remove $user?"),
              actions: [
                FlatButton(onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),),
                FlatButton(onPressed: () {
                  bloc.removeUser(user);
                  Navigator.pop(context);
                }, child: Text("Ok"))
              ],
            )
    );
  }
}
