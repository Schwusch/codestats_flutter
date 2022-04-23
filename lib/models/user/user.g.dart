// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      (json['totalMachines'] as List<dynamic>)
          .map((e) => Xp.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['totalLangs'] as List<dynamic>)
          .map((e) => Xp.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['recentMachines'] as List<dynamic>)
          .map((e) => Xp.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['recentLangs'] as List<dynamic>)
          .map((e) => Xp.fromJson(e as Map<String, dynamic>))
          .toList(),
      Map<String, int>.from(json['hourOfDayXps'] as Map),
      Map<String, int>.from(json['dayOfYearXps'] as Map),
      (json['dayLanguageXps'] as List<dynamic>)
          .map((e) => DayLanguageXps.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['totalXp'] as int,
      json['registered'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'totalMachines': instance.totalMachines,
      'totalLangs': instance.totalLangs,
      'recentMachines': instance.recentMachines,
      'recentLangs': instance.recentLangs,
      'hourOfDayXps': instance.hourOfDayXps,
      'dayOfYearXps': instance.dayOfYearXps,
      'dayLanguageXps': instance.dayLanguageXps,
      'registered': instance.registered,
      'totalXp': instance.totalXp,
    };
