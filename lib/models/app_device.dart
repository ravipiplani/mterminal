import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'app_device.g.dart';

enum DeviceType {
  @JsonValue(1)
  desktop,
  @JsonValue(2)
  mobile
}

@JsonSerializable()
class AppDevice {
  AppDevice(
      {required this.model,
      required this.identifier,
      required this.id,
      required this.name,
      required this.lastActiveAt,
      required this.type,
      required this.token});

  factory AppDevice.fromJson(Map<String, dynamic> json) => _$AppDeviceFromJson(json);

  final int id;
  final String name;
  final DeviceType type;
  final String model;
  final String identifier;
  @JsonKey(name: Keys.lastActiveAt)
  final DateTime lastActiveAt;
  final String token;

  Map<String, dynamic> toJson() => _$AppDeviceToJson(this);

  @override
  String toString() {
    return 'AppDevice{id: $id, name: $name, type: $type, model: $model, identifier: $identifier, lastActiveAt: $lastActiveAt, token: $token}';
  }
}
