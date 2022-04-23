import 'package:json_annotation/json_annotation.dart';

part 'xp.g.dart';

@JsonSerializable()
class PulseXp {
  final int amount;
  final String language;

  PulseXp(this.amount, this.language);

  factory PulseXp.fromJson(Map<String, dynamic> json) =>
      _$PulseXpFromJson(json);

  Map<String, dynamic> toJson() => _$PulseXpToJson(this);

  @override
  String toString() => "$language: $amount XP";
}
