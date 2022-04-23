import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/day_language_xps.dart';
import 'package:codestats_flutter/widgets/day_of_year_xps.dart';
import 'package:codestats_flutter/widgets/language_levels.dart';
import 'package:codestats_flutter/widgets/no_user.dart';
import 'package:codestats_flutter/widgets/profile_page.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:flutter/material.dart';

class DashBoardBody extends StatefulWidget {
  final UserBloc bloc;

  const DashBoardBody({Key? key, required this.bloc}) : super(key: key);

  @override
  _DashBoardBodyState createState() => _DashBoardBodyState();
}

class _DashBoardBodyState extends State<DashBoardBody> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.bloc.currentUser,
      initialData: UserWrap(),
      builder: (BuildContext context, AsyncSnapshot<UserWrap> snapshot) {
        var user = snapshot.data!;
        if (user.name != null && user.name!.isNotEmpty && user.data == null) {
          return const Center(
            child: RandomLoadingAnimation(),
          );
        } else if (user.name == null || user.name!.isEmpty) {
          widget.bloc.selectNextUser();
          return NoUser();
        } else {
          return TabBarView(
            children: [
              ProfilePage(
                user: user,
              ),
              DayLanguageXpsWidget(
                userModel: user.data,
              ),
              LanguageLevelPage(
                userModel: user.data,
              ),
              DayOfYearXps(
                userModel: user.data,
                scrollController: ScrollController(),
              )
            ],
          );
        }
      },
    );
  }
}
