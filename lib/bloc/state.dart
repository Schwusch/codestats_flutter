import 'package:codestats_flutter/models/user/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'state.g.dart';

@JsonSerializable(nullable: true, useWrappers: true)
class UserState {
  Map<String, User> allUsers;

  UserState({
    this.allUsers
  });

  factory UserState.empty() => UserState(allUsers: {});

  factory UserState.fromJson(Map<String, dynamic> json) => _$UserStateFromJson(json);
  Map<String, dynamic> toJson() => _$UserStateToJson(this);
}