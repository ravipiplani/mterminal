part of 'team_bloc.dart';

abstract class TeamState {
  const TeamState();
}

class UninitializedState extends TeamState {}

// Retrieve Team
class RetrievingTeamState extends TeamState {}

class TeamRetrievedState extends TeamState {
  TeamRetrievedState({required this.team});

  final Team team;

  List<Object> get props => [team];
}

class RetrievingTeamErrorState extends TeamState {
  RetrievingTeamErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

// Update Team
class UpdatingTeamState extends TeamState {}

class TeamUpdatedState extends TeamState {
  TeamUpdatedState({required this.team});

  final Team team;

  List<Object> get props => [team];
}

class UpdatingTeamErrorState extends TeamState {
  UpdatingTeamErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

// Invite User
class InvitingUserState extends TeamState {}

class UserInvitedState extends TeamState {
  UserInvitedState({required this.message});

  final String message;

  List<Object> get props => [message];
}

class InvitingUserErrorState extends TeamState {
  InvitingUserErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

// Cancel Invite
class CancellingInviteState extends TeamState {}

class InviteCancelledState extends TeamState {
  InviteCancelledState({required this.message});

  final String message;

  List<Object> get props => [message];
}

class CancellingInviteErrorState extends TeamState {
  CancellingInviteErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

// Accept Team Invite
class AcceptingTeamInviteState extends TeamState {}

class TeamInviteAcceptedState extends TeamState {
  TeamInviteAcceptedState({required this.isSignedUp, required this.email});

  final bool isSignedUp;
  final String email;

  List<Object> get props => [isSignedUp, email];
}

class AcceptingTeamInviteErrorState extends TeamState {
  AcceptingTeamInviteErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

// Create Team
class CreatingTeamState extends TeamState {}

class TeamCreatedState extends TeamState {
  TeamCreatedState({required this.team});

  final Team team;

  List<Object> get props => [team];
}

class CreatingTeamErrorState extends TeamState {
  CreatingTeamErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
