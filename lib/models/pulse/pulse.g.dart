// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pulse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pulse _$PulseFromJson(Map<String, dynamic> json) {
  return Pulse(
      json['machine'] as String,
      json['sent_at'] as String,
      json['sent_at_local'] as String,
      (json['xps'] as List)
          ?.map((e) =>
              e == null ? null : PulseXp.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$PulseToJson(Pulse instance) =>
    _$PulseJsonMapWrapper(instance);

class _$PulseJsonMapWrapper extends $JsonMapWrapper {
  final Pulse _v;
  _$PulseJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys =>
      const ['machine', 'sent_at', 'sent_at_local', 'xps'];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'machine':
          return _v.machine;
        case 'sent_at':
          return _v.sent_at;
        case 'sent_at_local':
          return _v.sent_at_local;
        case 'xps':
          return _v.xps;
      }
    }
    return null;
  }
}
