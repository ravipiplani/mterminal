part of 'team_bloc.dart';

abstract class TeamEvent {}

class UninitializedEvent extends TeamEvent {}

class GetTeamEvent extends TeamEvent {
  GetTeamEvent({required this.teamId});

  final int teamId;

  List<Object> get props => [teamId];
}

class UpdateTeamEvent extends TeamEvent {
  UpdateTeamEvent({required this.teamId, required this.data});

  final int teamId;
  final Map<String, dynamic> data;

  List<Object> get props => [teamId, data];
}

class InviteUserEvent extends TeamEvent {
  InviteUserEvent({required this.teamId, required this.email, required this.role});

  final int teamId;
  final String email;
  final int role;

  List<Object> get props => [teamId, email, role];
}

class CancelInviteEvent extends TeamEvent {
  CancelInviteEvent({required this.teamId, required this.teamInviteId});

  final int teamId;
  final int teamInviteId;

  List<Object> get props => [teamId, teamInviteId];
}

class AcceptTeamInviteEvent extends TeamEvent {
  AcceptTeamInviteEvent({required this.iid, required this.uid, required this.token});

  final String iid;
  final String uid;
  final String token;

  List<Object> get props => [iid, uid, token];
}

class CreateTeamEvent extends TeamEvent {
  CreateTeamEvent({required this.name});

  final String name;

  List<Object> get props => [name];
}
