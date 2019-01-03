import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/utils.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserBloc _userBloc = BlocProvider.of(context);
    final TextEditingController _textEditingController =
        TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: Text("Add user"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                textInputAction: TextInputAction.go,
                controller: _textEditingController,
                style: TextStyle(fontSize: 24, color: Colors.blueGrey),
                decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: 'Username',
                ),
                onChanged: _userBloc.searchUser.add,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: _userBloc.userValidation,
                  builder: (context, AsyncSnapshot<ValidUser> snapshot) {
                    if (snapshot.data == ValidUser.Unknown ||
                        snapshot.data == ValidUser.Valid) {
                      return Container();
                    } else if (snapshot.data == ValidUser.Error) {
                      return Text(
                        "Network error",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      );
                    } else if (snapshot.data == ValidUser.Invalid) {
                      return Column(
                        children: <Widget>[
                          Text(
                            "No user named:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            "'${_textEditingController.text.trim()}'",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return RandomLoadingAnimation(
                        size: 24,
                      );
                    }
                  },
                ),
              ),
              StreamBuilder(
                stream: _userBloc.searchResult,
                builder:
                    (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    final formatter = NumberFormat("#,###");
                    var totalXp = snapshot.data["total_xp"] ?? 0;
                    var userName = snapshot.data["user"];

                    return Card(
                      child: ListTile(
                        title: Text(
                            snapshot.data["user"] ?? "Empty search result"),
                        subtitle: Text(
                          "Level ${getLevel(totalXp)}, ${formatter.format(totalXp)} XP",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                        trailing: userName != null
                            ? IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  _userBloc.setUserValidation
                                      .add(ValidUser.Unknown);
                                  _userBloc.addUser(userName);
                                  _textEditingController.clear();
                                  Navigator.of(context).pop();
                                },
                              )
                            : null,
                      ),
                    );
                  } else
                    return Container();
                },
              ),
            ],
          ),
        ));
  }
}
