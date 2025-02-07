import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';
import 'team.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User({
    required this.id,
    required this.uuid,
    this.lastLogin,
    this.firstName,
    this.lastName,
    required this.email,
    required this.teams,
    required this.isEmailVerified
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final int id;
  final String uuid;
  @JsonKey(name: Keys.lastLogin)
  final DateTime? lastLogin;
  @JsonKey(name: Keys.firstName)
  final String? firstName;
  @JsonKey(name: Keys.lastName)
  final String? lastName;
  final String email;
  @JsonKey(defaultValue: [])
  final List<Team> teams;
  @JsonKey(name: Keys.isEmailVerified)
  final bool isEmailVerified;

  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName {
    return '$firstName $lastName';
  }

  @override
  String toString() {
    return 'User{id: $id, uuid: $uuid, lastLogin: $lastLogin, firstName: $firstName, lastName: $lastName, email: $email, teams: $teams, isEmailVerified: $isEmailVerified}';
  }
}
