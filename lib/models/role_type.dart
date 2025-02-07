import 'package:json_annotation/json_annotation.dart';

enum RoleType {
  @JsonValue(1)
  admin,
  @JsonValue(2)
  developer
}