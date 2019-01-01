import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/widgets/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:superpower/superpower.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:package_info/package_info.dart';

class Settings extends StatelessWidget {
  final Map<String, User> users;
  final UserBloc bloc;

  const Settings({
    Key key,
    @required this.users,
    @required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");

    List<Widget> widgets = [
      ListTile(
        title: Text(
          "Users",
          style: TextStyle(
              color: Colors.blueGrey.shade100,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        trailing: IconButton(
          color: Colors.white,
          icon: Icon(Icons.add_circle_outline),
          onPressed: () {
            Navigator.of(context).pushNamed("/addUser");
          },
        ),
      ),
    ];

    if (users != null && users.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Divider(
            color: Colors.blueGrey.shade200,
          ),
        ),
      );
      widgets.addAll(
        $(users.keys).sorted().mapNotNull((user) {
          if (bloc.state.allUsers[user] == null) {
            return null;
          }

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
              "${formatter.format(bloc.state.allUsers[user]?.totalXp)} XP",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            leading: CircleAvatar(
              child: Text("${getLevel(bloc.state.allUsers[user]?.totalXp)}"),
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
      );
    }

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Divider(
          color: Colors.blueGrey.shade200,
        ),
      ),
    );

    widgets.add(ListTile(
      onTap: () async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        showAboutDialog(
          context: context,
          applicationIcon: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/icon/ic_launcher.png"),
          ),
          children: [
            Text("The Code::Stats logo is licensed with CC BY-NC 4.0"),
            Text("Copyright © 2016, Mikko Ahlroth"),
          ],
          applicationVersion: packageInfo.version,
          applicationName: packageInfo.appName,
        );
      },
      leading: Icon(
        Icons.info,
        color: Colors.white,
      ),
      title: Text(
        "About Code::Stats",
        style: TextStyle(color: Colors.white),
      ),
    ));

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: ListView(
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        children: widgets,
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
            bloc.removeUser(user);
            Navigator.pop(context);
          },
          color: Colors.deepOrange,
        )
      ],
    ).show();
  }
}
