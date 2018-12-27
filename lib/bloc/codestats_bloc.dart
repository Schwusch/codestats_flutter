import 'package:bloc/bloc.dart';
import 'package:codestats_flutter/bloc/events.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  @override
  UserState get initialState => UserState(currentUser: "Schwusch", allUsers: ["Schwusch", "MasterBait"]);

  @override
  Stream<UserState> mapEventToState(
      UserState currentState, UserEvent event) async* {
    if (event is ChangeUser) {
      yield currentState..currentUser = event.username;
    }
    if (event is AddUser) {
      yield currentState..allUsers.add(event.username);
    }
    if (event is RemoveUser) {
      yield currentState..allUsers.remove(event.username);
    }
  }
}

class UserState {
  String currentUser;
  List<String> allUsers = [];

  UserState({
    this.currentUser,
    this.allUsers = const [],
  });
}
