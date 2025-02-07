// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      id: json['id'] as int,
      name: json['name'] as String,
      activeLicense:
          License.fromJson(json['active_license'] as Map<String, dynamic>),
      teamUsers: (json['team_users'] as List<dynamic>?)
              ?.map((e) => TeamUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      teamInvites: (json['team_invites'] as List<dynamic>?)
              ?.map((e) => TeamInvite.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'active_license': instance.activeLicense,
      'team_users': instance.teamUsers,
      'team_invites': instance.teamInvites,
    };
