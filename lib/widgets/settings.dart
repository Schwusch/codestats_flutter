import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/widgets/expandable_user_list.dart';
import 'package:codestats_flutter/widgets/recent_period_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserBloc>();

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: ListView(
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        children: [
          ListTile(
            title: Text(
              "Nr of days in 'Recent' tab",
              style: TextStyle(
                  color: Colors.blueGrey.shade100,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
          ),
          const RecentPeriodSettings(),
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
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                Navigator.of(context).pushNamed("addUser");
              },
            ),
          ),
          StreamBuilder(
            stream: bloc.userStateController,
            builder: (context, AsyncSnapshot<UserState> snapshot) {
              var users = snapshot.data?.allUsers;
              if (users != null && users.isNotEmpty) {
                return ExpandableUserList(
                  key: UniqueKey(),
                  users: users.keys.toList()..sort(),
                );
              } else {
                return Container();
              }
            },
          ),
          ListTile(
            onTap: () async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();
              showAboutDialog(
                context: context,
                applicationIcon: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.asset("assets/icon/ic_launcher.png"),
                ),
                children: [
                  const Text(
                      "The Code::Stats logo is licensed with CC BY-NC 4.0"),
                  const Text("Copyright © 2016, Mikko Ahlroth"),
                ],
                applicationVersion: packageInfo.version,
                applicationName: packageInfo.appName,
              );
            },
            leading: const Icon(
              Icons.info,
              color: Colors.white,
            ),
            title: const Text(
              "About Code::Stats",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
