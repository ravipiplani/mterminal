// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamInvite _$TeamInviteFromJson(Map<String, dynamic> json) => TeamInvite(
      id: json['id'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      role: $enumDecode(_$RoleTypeEnumMap, json['role']),
      roleLabel: json['role_label'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TeamInviteToJson(TeamInvite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'role': _$RoleTypeEnumMap[instance.role]!,
      'role_label': instance.roleLabel,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$RoleTypeEnumMap = {
  RoleType.admin: 1,
  RoleType.developer: 2,
};
