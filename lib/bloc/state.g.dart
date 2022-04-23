// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserState _$UserStateFromJson(Map<String, dynamic> json) => UserState(
      allUsers: (json['allUsers'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, e == null ? null : User.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$UserStateToJson(UserState instance) => <String, dynamic>{
      'allUsers': instance.allUsers,
    };
