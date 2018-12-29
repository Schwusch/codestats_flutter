import 'package:codestats_flutter/models/user/day_language_xps.dart';
import 'package:codestats_flutter/models/user/xp.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(nullable: true, useWrappers: true)
class User {
  final List<Xp> totalMachines;
  final List<Xp> totalLangs;
  final List<Xp> recentMachines;
  final List<Xp> recentLangs;
  final Map<String, int> hourOfDayXps;
  final Map<String, int> dayOfYearXps;
  final List<DayLanguageXps> dayLanguageXps;
  int totalXp;

  User(this.totalMachines, this.totalLangs, this.recentMachines, this.recentLangs, this.hourOfDayXps, this.dayOfYearXps, this.dayLanguageXps, this.totalXp);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}