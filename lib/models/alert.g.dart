// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: $enumDecode(_$PriorityEnumMap, json['priority']),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiryAt: json['expiry_at'] == null
          ? null
          : DateTime.parse(json['expiry_at'] as String),
      link: json['link'] as String?,
    );

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'created_at': instance.createdAt.toIso8601String(),
      'expiry_at': instance.expiryAt?.toIso8601String(),
      'link': instance.link,
    };

const _$PriorityEnumMap = {
  Priority.low: 0,
  Priority.medium: 1,
  Priority.high: 2,
};
