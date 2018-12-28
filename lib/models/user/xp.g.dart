// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Xp _$XpFromJson(Map<String, dynamic> json) {
  return Xp(json['xp'] as int, json['name'] as String);
}

Map<String, dynamic> _$XpToJson(Xp instance) => _$XpJsonMapWrapper(instance);

class _$XpJsonMapWrapper extends $JsonMapWrapper {
  final Xp _v;
  _$XpJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys => const ['xp', 'name'];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'xp':
          return _v.xp;
        case 'name':
          return _v.name;
      }
    }
    return null;
  }
}
