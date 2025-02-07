import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../config/keys.dart';
import '../../../models/team.dart';
import '../../../services/team_service.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  TeamBloc() : super(UninitializedState()) {
    on<GetTeamEvent>(_onGetTeamEvent);
    on<UpdateTeamEvent>(_onUpdateTeamEvent);
    on<InviteUserEvent>(_onInviteUserEvent);
    on<CancelInviteEvent>(_onCancelInviteEvent);
    on<AcceptTeamInviteEvent>(_onAcceptInviteEvent);
    on<CreateTeamEvent>(_onCreateTeamEvent);
  }

  final _teamService = TeamService();

  TeamState get initialState => UninitializedState();

  Future<void> _onGetTeamEvent(GetTeamEvent event, Emitter<TeamState> emit) async {
    emit(RetrievingTeamState());
    try {
      final team = await _teamService.getById(id: event.teamId);
      emit(TeamRetrievedState(team: team));
    } on Exception catch (e) {
      emit(RetrievingTeamErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateTeamEvent(UpdateTeamEvent event, Emitter<TeamState> emit) async {
    emit(UpdatingTeamState());
    try {
      final team = await _teamService.update(id: event.teamId, data: event.data);
      emit(TeamUpdatedState(team: team));
    } on Exception catch (e) {
      emit(UpdatingTeamErrorState(message: e.toString()));
    }
  }

  Future<void> _onInviteUserEvent(InviteUserEvent event, Emitter<TeamState> emit) async {
    emit(InvitingUserState());
    try {
      final message = await _teamService.inviteUser(id: event.teamId, email: event.email, role: event.role);
      emit(UserInvitedState(message: message));
    } on Exception catch (e) {
      emit(InvitingUserErrorState(message: e.toString()));
    }
  }

  Future<void> _onCancelInviteEvent(CancelInviteEvent event, Emitter<TeamState> emit) async {
    emit(CancellingInviteState());
    try {
      final message = await _teamService.cancelInvite(id: event.teamId, teamInviteId: event.teamInviteId);
      emit(InviteCancelledState(message: message));
    } on Exception catch (e) {
      emit(CancellingInviteErrorState(message: e.toString()));
    }
  }

  Future<void> _onAcceptInviteEvent(AcceptTeamInviteEvent event, Emitter<TeamState> emit) async {
    emit(AcceptingTeamInviteState());
    try {
      final response = await _teamService.acceptInvite(iid: event.iid, uid: event.uid, token: event.token);
      emit(TeamInviteAcceptedState(isSignedUp: response[Keys.isSignedUp], email: response[Keys.email]));
    } on Exception catch (e) {
      emit(AcceptingTeamInviteErrorState(message: e.toString()));
    }
  }

  Future<void> _onCreateTeamEvent(CreateTeamEvent event, Emitter<TeamState> emit) async {
    emit(CreatingTeamState());
    try {
      final team = await _teamService.create(name: event.name);
      emit(TeamCreatedState(team: team));
    } on Exception catch (e) {
      emit(CreatingTeamErrorState(message: e.toString()));
    }
  }
}
