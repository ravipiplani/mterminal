// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReleaseInfo _$ReleaseInfoFromJson(Map<String, dynamic> json) => ReleaseInfo(
      platform: $enumDecode(_$PlatformEnumMap, json['platform']),
      version: json['version'] as String,
      number: json['number'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String,
      binaryUrl: json['binary_url'] as String,
    );

Map<String, dynamic> _$ReleaseInfoToJson(ReleaseInfo instance) =>
    <String, dynamic>{
      'platform': _$PlatformEnumMap[instance.platform]!,
      'version': instance.version,
      'number': instance.number,
      'date': instance.date.toIso8601String(),
      'notes': instance.notes,
      'binary_url': instance.binaryUrl,
    };

const _$PlatformEnumMap = {
  Platform.macOS: 'macOS',
};
