import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

class ExpandableUser {
  final String user;
  bool isExpanded = false;

  ExpandableUser({@required this.user});

  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          color: Colors.white,
          icon: Icon(
            Icons.share,
          ),
          onPressed: () => Share.share("https://codestats.net/users/$user"),
        ),
        IconButton(
          color: Colors.white,
          icon: Icon(Icons.delete),
          onPressed: () {
            _onAlertButtonsPressed(context, user, bloc);
          },
        )
      ],
    );
  }

  ExpansionPanelHeaderBuilder get headerBuilder =>
      (BuildContext context, bool isExpanded) {
        UserBloc bloc = BlocProvider.of(context);
        final formatter = NumberFormat("#,###");
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
            "${formatter.format(bloc.userStateController.value.allUsers[user]?.totalXp ?? 0)} XP",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: CircleAvatar(
            child: Text(
                "${getLevel(bloc.userStateController.value.allUsers[user]?.totalXp ?? 0)}"),
          ),
        );
      };

  _onAlertButtonsPressed(BuildContext context, String user, UserBloc bloc) {
    Alert(
      style: AlertStyle(
        animationType: AnimationType.grow,
      ),
      context: context,
      type: AlertType.warning,
      title: "Remove $user?",
      buttons: [
        DialogButton(
          child: Text(
            "CANCEL",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.green,
        ),
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            bloc.removeUser(user);
            Navigator.pop(context);
          },
          color: Colors.deepOrange,
        )
      ],
    ).show();
  }
}
