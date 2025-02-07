import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../services/authentication_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(UninitializedState()) {
    on<SignUpEvent>(_onSignUpEvent);
    on<LogInEvent>(_onLogInEvent);
    on<LogOutEvent>(_onLogOutEvent);
    on<RefreshTokenEvent>(_onRefreshTokenEvent);
    on<VerifyEmailEvent>(_onVerifyEmailEvent);
    on<SendResetPasswordLinkEvent>(_onSendResetPasswordLinkEvent);
    on<ResetPasswordEvent>(_onResetPasswordEvent);
  }

  final _authService = AuthenticationService();

  AuthenticationState get initialState => UninitializedState();

  Future<void> _onSignUpEvent(SignUpEvent event, Emitter<AuthenticationState> emit) async {
    emit(SigningUpState());
    try {
      await _authService.signUp(data: event.data);
      emit(SignedUpState());
    } on Exception catch (e) {
      emit(SigningUpErrorState(message: e.toString()));
    }
  }

  Future<void> _onLogInEvent(LogInEvent event, Emitter<AuthenticationState> emit) async {
    emit(LoggingInState());
    try {
      await _authService.logIn(email: event.email, password: event.password);
      emit(LoggedInState());
    } on Exception catch (e) {
      emit(LoggingInErrorState(message: e.toString()));
    }
  }

  Future<void> _onLogOutEvent(LogOutEvent event, Emitter<AuthenticationState> emit) async {
    emit(LoggingOutState());
    try {
      await _authService.logOut(token: event.token);
      emit(LoggedOutState());
    } on Exception {
      emit(LoggedOutState());
    }
  }

  Future<void> _onRefreshTokenEvent(RefreshTokenEvent event, Emitter<AuthenticationState> emit) async {
    emit(RefreshingTokenState());
    try {
      await _authService.refresh(refresh: event.refresh);
      emit(TokenRefreshedState());
    } on Exception catch (e) {
      emit(RefreshingTokenErrorState(message: e.toString()));
    }
  }

  Future<void> _onVerifyEmailEvent(VerifyEmailEvent event, Emitter<AuthenticationState> emit) async {
    emit(VerifyingEmailState());
    try {
      await _authService.verifyEmail(uid: event.uid, token: event.token);
      emit(EmailVerifiedState());
    } on Exception catch (e) {
      emit(VerifyingEmailErrorState(message: e.toString()));
    }
  }

  Future<void> _onSendResetPasswordLinkEvent(SendResetPasswordLinkEvent event, Emitter<AuthenticationState> emit) async {
    emit(SendingResetPasswordLinkState());
    try {
      final message = await _authService.sendResetPasswordLink(email: event.email);
      emit(ResetPasswordLinkSentState(message: message));
    } on Exception catch (e) {
      emit(SendingResetPasswordLinkErrorState(message: e.toString()));
    }
  }

  Future<void> _onResetPasswordEvent(ResetPasswordEvent event, Emitter<AuthenticationState> emit) async {
    emit(ResettingPasswordState());
    try {
      final message = await _authService.resetPassword(uid: event.uid, token: event.token, password: event.password);
      emit(PasswordResetState(message: message));
    } on Exception catch (e) {
      emit(ResettingPasswordErrorState(message: e.toString()));
    }
  }
}
