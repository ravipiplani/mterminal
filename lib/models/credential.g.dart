// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Credential _$CredentialFromJson(Map<String, dynamic> json) => Credential(
      id: json['id'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$CredentialTypeEnumMap, json['type']),
      password: json['password'] as String?,
      privateKey: json['private_key'] as String?,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$CredentialToJson(Credential instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CredentialTypeEnumMap[instance.type]!,
      'password': instance.password,
      'private_key': instance.privateKey,
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

const _$CredentialTypeEnumMap = {
  CredentialType.password: 1,
  CredentialType.pemKey: 2,
};
