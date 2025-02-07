// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppDevice _$AppDeviceFromJson(Map<String, dynamic> json) => AppDevice(
      model: json['model'] as String,
      identifier: json['identifier'] as String,
      id: json['id'] as int,
      name: json['name'] as String,
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
      type: $enumDecode(_$DeviceTypeEnumMap, json['type']),
      token: json['token'] as String,
    );

Map<String, dynamic> _$AppDeviceToJson(AppDevice instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$DeviceTypeEnumMap[instance.type]!,
      'model': instance.model,
      'identifier': instance.identifier,
      'last_active_at': instance.lastActiveAt.toIso8601String(),
      'token': instance.token,
    };

const _$DeviceTypeEnumMap = {
  DeviceType.desktop: 1,
  DeviceType.mobile: 2,
};
