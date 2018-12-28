import 'package:json_annotation/json_annotation.dart';

part 'xp.g.dart';

@JsonSerializable(nullable: true, useWrappers: true)
class Xp {
  int xp;
  final String name;

  Xp(this.xp, this.name);

  factory Xp.fromJson(Map<String, dynamic> json) => _$XpFromJson(json);

  Map<String, dynamic> toJson() => _$XpToJson(this);
}
