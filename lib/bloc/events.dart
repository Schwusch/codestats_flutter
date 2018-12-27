
abstract class UserEvent {}

class ChangeUser extends UserEvent {
  final String username;

  ChangeUser(this.username);

  @override
  String toString() => 'ChangeUser: $username';
}

class AddUser extends UserEvent {
  final String username;

  AddUser(this.username);

  @override
  String toString() => 'AddUser: $username';
}

class RemoveUser extends UserEvent {
  final String username;

  RemoveUser(this.username);

  @override
  String toString() => 'RemoveUser: $username';
}