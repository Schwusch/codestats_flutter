// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pulse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pulse _$PulseFromJson(Map<String, dynamic> json) => Pulse(
      json['machine'] as String?,
      json['sent_at'] as String?,
      json['sent_at_local'] as String?,
      (json['xps'] as List<dynamic>)
          .map((e) => PulseXp.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PulseToJson(Pulse instance) => <String, dynamic>{
      'machine': instance.machine,
      'sent_at': instance.sent_at,
      'sent_at_local': instance.sent_at_local,
      'xps': instance.xps,
    };
