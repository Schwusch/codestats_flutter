import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/bloc/state.dart';
import 'package:codestats_flutter/widgets/expandable_user_list.dart';
import 'package:codestats_flutter/widgets/recent_period_selector.dart';
import 'package:flutter/material.dart';
import 'package:superpower/superpower.dart';
//import 'package:package_info/package_info.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);

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
          RecentPeriodSettings(),
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
                  users: $(users.keys).sorted(),
                );
              } else
                return Container();
            },
          ),
          ListTile(
            onTap: () async {
              //PackageInfo packageInfo = await PackageInfo.fromPlatform();
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
                //applicationVersion: packageInfo.version,
                //applicationName: packageInfo.appName,
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
          )
        ],
      ),
    );
  }
}
