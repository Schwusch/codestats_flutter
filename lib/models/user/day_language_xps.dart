import 'package:json_annotation/json_annotation.dart';

part 'day_language_xps.g.dart';

@JsonSerializable(nullable: true, useWrappers: true)
class DayLanguageXps {
  final int xp;
  final String language;
  final String date;

  DayLanguageXps(this.xp, this.language, this.date);

  factory DayLanguageXps.fromJson(Map<String, dynamic> json) => _$DayLanguageXpsFromJson(json);

  Map<String, dynamic> toJson() => _$DayLanguageXpsToJson(this);
}