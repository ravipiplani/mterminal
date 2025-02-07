import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../models/user.dart';
import '../../../services/user_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UninitializedState()) {
    on<GetUserEvent>(_onGetUserEvent);
    on<ChangePasswordEvent>(_onChangePasswordEvent);
    on<ChangeEmailEvent>(_onChangeEmailEvent);
    on<ResendEmailVerificationLinkEvent>(_onResendEmailVerificationLinkEvent);
    on<DeleteAccountEvent>(_onDeleteAccountEvent);
  }

  final _userService = UserService();

  UserState get initialState => UninitializedState();

  Future<void> _onGetUserEvent(GetUserEvent event, Emitter<UserState> emit) async {
    emit(RetrievingUserState());
    try {
      final user = await _userService.me();
      emit(UserRetrievedState(user: user));
    } on Exception catch (e) {
      emit(RetrievingUserErrorState(message: e.toString()));
    }
  }

  Future<void> _onChangePasswordEvent(ChangePasswordEvent event, Emitter<UserState> emit) async {
    emit(ChangingPasswordState());
    try {
      await _userService.changePassword(userId: event.userId, data: event.data);
      emit(PasswordChangedState());
    } on Exception catch (e) {
      emit(ChangingPasswordErrorState(message: e.toString()));
    }
  }

  Future<void> _onChangeEmailEvent(ChangeEmailEvent event, Emitter<UserState> emit) async {
    emit(ChangingEmailState());
    try {
      await _userService.changeEmail(userId: event.userId, data: event.data);
      emit(EmailChangedState());
    } on Exception catch (e) {
      emit(ChangingEmailErrorState(message: e.toString()));
    }
  }

  Future<void> _onResendEmailVerificationLinkEvent(ResendEmailVerificationLinkEvent event, Emitter<UserState> emit) async {
    emit(ResendingEmailVerificationLinkState());
    try {
      await _userService.resendVerificationLink(userId: event.userId);
      emit(EmailVerificationLinkResentState());
    } on Exception catch (e) {
      emit(ResendingEmailVerificationLinkErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteAccountEvent(DeleteAccountEvent event, Emitter<UserState> emit) async {
    emit(DeletingAccountState());
    try {
      final message = await _userService.deleteAccount(password: event.password);
      emit(AccountDeletedState(message: message));
    } on Exception catch (e) {
      emit(DeletingAccountErrorState(message: e.toString()));
    }
  }
}
