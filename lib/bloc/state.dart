import 'package:codestats_flutter/models/user/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'state.g.dart';

@JsonSerializable()
class UserState {
  Map<String, User?> allUsers;

  UserState({required this.allUsers});

  factory UserState.empty() => UserState(allUsers: {});

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);
  Map<String, dynamic> toJson() => _$UserStateToJson(this);
}
