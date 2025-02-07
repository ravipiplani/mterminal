// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
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
      id: json['id'] as int,
      name: json['name'] as String,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'remote_id': instance.remoteId,
      'local_updated_on': instance.localUpdatedOn?.toIso8601String(),
      'remote_updated_on': instance.remoteUpdatedOn?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
