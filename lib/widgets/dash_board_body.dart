import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/models/user/user.dart';
import 'package:codestats_flutter/widgets/day_language_xps.dart';
import 'package:codestats_flutter/widgets/day_of_year_xps.dart';
import 'package:codestats_flutter/widgets/language_levels.dart';
import 'package:codestats_flutter/widgets/no_user.dart';
import 'package:codestats_flutter/widgets/profile_page.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DashBoardBody extends StatefulWidget {
  final UserBloc bloc;

  const DashBoardBody({Key key, @required this.bloc}) : super(key: key);

  @override
  _DashBoardBodyState createState() => _DashBoardBodyState();
}

class _DashBoardBodyState extends State<DashBoardBody> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream(
        [widget.bloc.userStateController as Stream, widget.bloc.selectedUser],
        (values) => values,
      ),
      initialData: [null, null],
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        String currentUser = snapshot.data[1] ?? "";
        Map<String, User> users = snapshot.data[0]?.allUsers ?? {};
        User userModel = users[currentUser];

        if (currentUser != null &&
            currentUser.isNotEmpty &&
            userModel == null) {
          return Center(
            child: RandomLoadingAnimation(),
          );
        } else if (currentUser == null || currentUser.isEmpty) {
          if (users != null && users.isNotEmpty) {
            widget.bloc.selectUser.add(users.keys.first);
          }
          return NoUser();
        } else {
          return TabBarView(
            children: [
              ProfilePage(
                userModel: userModel,
                userName: currentUser,
              ),
              DayLanguageXpsWidget(
                userModel: userModel,
              ),
              LanguageLevelPage(
                userModel: userModel,
              ),
              DayOfYearXps(
                userModel: userModel,
                scrollController: ScrollController(),
              )
            ],
          );
        }
      },
    );
  }
}
