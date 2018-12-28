// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      (json['totalMachines'] as List)
          ?.map(
              (e) => e == null ? null : Xp.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['totalLangs'] as List)
          ?.map(
              (e) => e == null ? null : Xp.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['recentMachines'] as List)
          ?.map(
              (e) => e == null ? null : Xp.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['recentLangs'] as List)
          ?.map(
              (e) => e == null ? null : Xp.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['hourOfDayXps'] as Map<String, dynamic>)
          ?.map((k, e) => MapEntry(k, e as int)),
      (json['dayOfYearXps'] as Map<String, dynamic>)
          ?.map((k, e) => MapEntry(k, e as int)),
      (json['dayLanguageXps'] as List)
          ?.map((e) => e == null
              ? null
              : DayLanguageXps.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['totalXp'] as int);
}

Map<String, dynamic> _$UserToJson(User instance) =>
    _$UserJsonMapWrapper(instance);

class _$UserJsonMapWrapper extends $JsonMapWrapper {
  final User _v;
  _$UserJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys => const [
        'totalMachines',
        'totalLangs',
        'recentMachines',
        'recentLangs',
        'hourOfDayXps',
        'dayOfYearXps',
        'dayLanguageXps',
        'totalXp'
      ];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'totalMachines':
          return _v.totalMachines;
        case 'totalLangs':
          return _v.totalLangs;
        case 'recentMachines':
          return _v.recentMachines;
        case 'recentLangs':
          return _v.recentLangs;
        case 'hourOfDayXps':
          return _v.hourOfDayXps;
        case 'dayOfYearXps':
          return _v.dayOfYearXps;
        case 'dayLanguageXps':
          return _v.dayLanguageXps;
        case 'totalXp':
          return _v.totalXp;
      }
    }
    return null;
  }
}
