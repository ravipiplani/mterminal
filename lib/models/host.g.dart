// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Host _$HostFromJson(Map<String, dynamic> json) => Host(
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      remoteId: json['remote_id'] as int?,
      localUpdatedOn: json['local_updated_on'] == null
          ? null
          : DateTime.parse(json['local_updated_on'] as String),
      remoteUpdatedOn: json['remote_updated_on'] == null
          ? null
          : DateTime.parse(json['remote_updated_on'] as String),
      address: json['address'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      credential: json['credential'] == null
          ? null
          : Credential.fromJson(json['credential'] as Map<String, dynamic>),
      id: json['id'] as int,
      name: json['name'] as String,
      tag: json['tag'] == null
          ? null
          : Tag.fromJson(json['tag'] as Map<String, dynamic>),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$HostToJson(Host instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'port': instance.port,
      'username': instance.username,
      'credential': instance.credential,
      'tag': instance.tag,
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'remote_id': instance.remoteId,
      'local_updated_on': instance.localUpdatedOn?.toIso8601String(),
      'remote_updated_on': instance.remoteUpdatedOn?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
