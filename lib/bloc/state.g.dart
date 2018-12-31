// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserState _$UserStateFromJson(Map<String, dynamic> json) {
  return UserState(
      allUsers: (json['allUsers'] as Map<String, dynamic>)?.map((k, e) =>
          MapEntry(
              k, e == null ? null : User.fromJson(e as Map<String, dynamic>))) ?? {});
}

Map<String, dynamic> _$UserStateToJson(UserState instance) =>
    _$UserStateJsonMapWrapper(instance);

class _$UserStateJsonMapWrapper extends $JsonMapWrapper {
  final UserState _v;
  _$UserStateJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys => const ['allUsers'];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'allUsers':
          return _v.allUsers;
      }
    }
    return null;
  }
}
