// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_share.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecureShare _$SecureShareFromJson(Map<String, dynamic> json) => SecureShare(
      id: json['id'] as int,
      data: json['data'] as String,
      isSingleUse: json['is_single_use'] as bool,
      iv: json['iv'] as String,
      expiryAt: DateTime.parse(json['expiry_at'] as String),
      accesses:
          (json['accesses'] as List<dynamic>).map((e) => e as int).toList(),
      createdBy: json['created_by'] as int,
    );

Map<String, dynamic> _$SecureShareToJson(SecureShare instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
      'is_single_use': instance.isSingleUse,
      'iv': instance.iv,
      'expiry_at': instance.expiryAt.toIso8601String(),
      'accesses': instance.accesses,
      'created_by': instance.createdBy,
    };
