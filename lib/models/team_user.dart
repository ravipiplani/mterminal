import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';
import 'role_type.dart';
import 'user.dart';

part 'team_user.g.dart';

@JsonSerializable()
class TeamUser {
  TeamUser({required this.user, required this.role, required this.roleLabel, required this.createdAt});

  factory TeamUser.fromJson(Map<String, dynamic> json) => _$TeamUserFromJson(json);

  final User user;
  final RoleType role;
  @JsonKey(name: Keys.roleLabel)
  final String roleLabel;
  @JsonKey(name: Keys.createdAt)
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$TeamUserToJson(this);

  @override
  String toString() {
    return 'TeamUser{user: $user, role: $role, roleLabel: $roleLabel, createdAt: $createdAt}';
  }
}
