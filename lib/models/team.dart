import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';
import 'license.dart';
import 'team_invite.dart';
import 'team_user.dart';

part 'team.g.dart';

@JsonSerializable()
class Team {
  Team({required this.id, required this.name, required this.activeLicense, required this.teamUsers, required this.teamInvites});

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  final int id;
  final String name;
  @JsonKey(name: Keys.activeLicense)
  final License activeLicense;
  @JsonKey(name: Keys.teamUsers, defaultValue: [])
  final List<TeamUser> teamUsers;
  @JsonKey(name: Keys.teamInvites, defaultValue: [])
  final List<TeamInvite> teamInvites;

  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  String toString() {
    return 'Team{id: $id, name: $name, activeLicense: $activeLicense, teamUsers: $teamUsers, teamInvites: $teamInvites}';
  }
}
