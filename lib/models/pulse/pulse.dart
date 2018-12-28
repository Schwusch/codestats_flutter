import 'package:codestats_flutter/models/pulse/xp.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pulse.g.dart';

@JsonSerializable(nullable: true, useWrappers: true)
class Pulse {
  final String machine;
  final String sent_at;
  final String sent_at_local;
  final List<PulseXp> xps;

  Pulse(this.machine, this.sent_at, this.sent_at_local, this.xps);

  factory Pulse.fromJson(Map<String, dynamic> json) => _$PulseFromJson(json);

  Map<String, dynamic> toJson() => _$PulseToJson(this);
}
