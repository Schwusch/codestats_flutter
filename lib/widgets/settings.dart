import 'dart:async';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:superpower/superpower.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Settings extends StatefulWidget {
  final Map<String, User> users;
  final UserBloc bloc;

  const Settings({
    Key key,
    @required this.users,
    @required this.bloc,
  }) : super(key: key);

  @override
  SettingsState createState() {
    return new SettingsState();
  }
}

class SettingsState extends State<Settings> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: ListView(
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 16),
            child: Text(
              "Users",
              style: TextStyle(
                  color: Colors.blueGrey.shade100,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
          ),
          ListTile(
            title: TextField(
              controller: _textEditingController,
              cursorColor: Colors.white,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'Username',
              ),
            ),
            trailing: StreamBuilder(
              stream: widget.bloc.userValidation,
              builder: (context, AsyncSnapshot<ValidUser> snapshot) {
                if (snapshot.data == ValidUser.Unknown) {
                  return IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      widget.bloc
                          .addUser(_textEditingController.value.text.trim());
                    },
                  );
                } else if (snapshot.data == ValidUser.Error) {
                  Timer(
                    Duration(seconds: 3),
                    () => widget.bloc.setUserValidation.add(ValidUser.Unknown),
                  );
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.signal_cellular_connected_no_internet_4_bar,
                      color: Colors.white,
                    ),
                  );
                } else if (snapshot.data == ValidUser.Invalid) {
                  Timer(
                    Duration(seconds: 3),
                    () => widget.bloc.setUserValidation.add(ValidUser.Unknown),
                  );
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                  );
                } else if (snapshot.data == ValidUser.Valid) {
                  _textEditingController.clear();
                  FocusScope.of(context).requestFocus(new FocusNode());
                  widget.bloc.setUserValidation.add(ValidUser.Unknown);
                  Backdrop.of(context).showFrontLayer();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: RandomLoadingAnimation(
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ]..addAll(
            $(widget.users.keys).sorted().mapNotNull((user) {
              if (widget.bloc.state.allUsers[user] == null) {
                return null;
              }

              return ListTile(
                onTap: () {
                  widget.bloc.selectUser.add(user);
                  Backdrop.of(context).fling();
                },
                title: Text(
                  user,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                    "${formatter.format(widget.bloc.state.allUsers[user]?.totalXp)} XP"),
                leading: CircleAvatar(
                  child: Text(
                      "${getLevel(widget.bloc.state.allUsers[user]?.totalXp)}"),
                ),
                trailing: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    _onAlertButtonsPressed(context, user);
                  },
                ),
              );
            }).toList(),
          ),
      ),
    );
  }

  _onAlertButtonsPressed(BuildContext context, String user) {
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
            widget.bloc.removeUser(user);
            Navigator.pop(context);
          },
          color: Colors.deepOrange,
        )
      ],
    ).show();
  }
}
