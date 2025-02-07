import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';
import 'role_type.dart';
import 'user.dart';

part 'team_invite.g.dart';

@JsonSerializable()
class TeamInvite {
  TeamInvite({required this.id, required this.user, required this.role, required this.roleLabel, required this.createdAt});

  factory TeamInvite.fromJson(Map<String, dynamic> json) => _$TeamInviteFromJson(json);

  final int id;
  final User user;
  final RoleType role;
  @JsonKey(name: Keys.roleLabel)
  final String roleLabel;
  @JsonKey(name: Keys.createdAt)
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$TeamInviteToJson(this);

  @override
  String toString() {
    return 'TeamInvite{id: $id, user: $user, role: $role, roleLabel: $roleLabel, createdAt: $createdAt}';
  }
}
