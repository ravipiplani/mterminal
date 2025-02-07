part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {}

class SignUpEvent extends AuthenticationEvent {
  SignUpEvent({required this.data});

  final Map<String, dynamic> data;

  List<Object> get props => [data];
}

class LogInEvent extends AuthenticationEvent {
  LogInEvent({required this.email, required this.password});

  final String email;
  final String password;

  List<Object> get props => [email];
}

class LogOutEvent extends AuthenticationEvent {
  LogOutEvent({this.token});

  final String? token;
}

class RefreshTokenEvent extends AuthenticationEvent {
  RefreshTokenEvent({required this.refresh});

  final String refresh;

  List<Object> get props => [refresh];
}

class VerifyEmailEvent extends AuthenticationEvent {
  VerifyEmailEvent({required this.uid, required this.token});

  final String uid;
  final String token;

  List<Object> get props => [uid, token];
}

class SendResetPasswordLinkEvent extends AuthenticationEvent {
  SendResetPasswordLinkEvent({required this.email});

  final String email;

  List<Object> get props => [email];
}

class ResetPasswordEvent extends AuthenticationEvent {
  ResetPasswordEvent({required this.uid, required this.token, required this.password});

  final String uid;
  final String token;
  final String password;

  List<Object> get props => [uid, token, password];
}
