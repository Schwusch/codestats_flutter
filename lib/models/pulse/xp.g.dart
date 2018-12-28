// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PulseXp _$PulseXpFromJson(Map<String, dynamic> json) {
  return PulseXp(json['amount'] as int, json['language'] as String);
}

Map<String, dynamic> _$PulseXpToJson(PulseXp instance) =>
    _$PulseXpJsonMapWrapper(instance);

class _$PulseXpJsonMapWrapper extends $JsonMapWrapper {
  final PulseXp _v;
  _$PulseXpJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys => const ['amount', 'language'];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'amount':
          return _v.amount;
        case 'language':
          return _v.language;
      }
    }
    return null;
  }
}
