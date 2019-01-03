import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/add_user_page.dart';
import 'package:codestats_flutter/widgets/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(CodeStatsApp()));
}

class CodeStatsApp extends StatelessWidget {
  final UserBloc _bloc = UserBloc()..fetchAllUsers();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
      bloc: _bloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Code::Stats',
        theme: ThemeData(
          textTheme: Typography(platform: TargetPlatform.android)
              .white
              .apply(bodyColor: Colors.blueGrey[600], displayColor: Colors.blueGrey[600]),
          primarySwatch: Colors.blueGrey,
        ),
        initialRoute: "/",
        routes: {
          "/": (_) => TabNavigator(),
          "/addUser": (_) => AddUserPage(),
        },
      ),
    );
  }
}
