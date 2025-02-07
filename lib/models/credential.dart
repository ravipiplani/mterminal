import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'credential.g.dart';

enum CredentialType {
  @JsonValue(1)
  password,
  @JsonValue(2)
  pemKey
}

@JsonSerializable()
class Credential {
  Credential({required this.id, required this.name, required this.type, this.password, this.privateKey, this.deletedAt});

  factory Credential.fromJson(Map<String, dynamic> json) => _$CredentialFromJson(json);

  final int id;
  final String name;
  final CredentialType type;
  final String? password;
  @JsonKey(name: Keys.privateKey)
  final String? privateKey;
  @JsonKey(name: Keys.deletedAt)
  final DateTime? deletedAt;

  Map<String, dynamic> toJson() => _$CredentialToJson(this);

  @override
  String toString() {
    return 'Credential{id: $id, name: $name, type: $type, deletedAt: $deletedAt}';
  }
}
