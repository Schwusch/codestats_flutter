// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_language_xps.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayLanguageXps _$DayLanguageXpsFromJson(Map<String, dynamic> json) {
  return DayLanguageXps(
      json['xp'] as int, json['language'] as String, json['date'] as String);
}

Map<String, dynamic> _$DayLanguageXpsToJson(DayLanguageXps instance) =>
    _$DayLanguageXpsJsonMapWrapper(instance);

class _$DayLanguageXpsJsonMapWrapper extends $JsonMapWrapper {
  final DayLanguageXps _v;
  _$DayLanguageXpsJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys => const ['xp', 'language', 'date'];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'xp':
          return _v.xp;
        case 'language':
          return _v.language;
        case 'date':
          return _v.date;
      }
    }
    return null;
  }
}
