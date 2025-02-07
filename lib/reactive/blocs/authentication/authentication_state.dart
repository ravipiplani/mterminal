part of 'authentication_bloc.dart';

abstract class AuthenticationState {
  const AuthenticationState();
}

class UninitializedState extends AuthenticationState {}

class SigningUpState extends AuthenticationState {}

class SignedUpState extends AuthenticationState {}

class SigningUpErrorState extends AuthenticationState {
  const SigningUpErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

class LoggingInState extends AuthenticationState {}

class LoggedInState extends AuthenticationState {}

class LoggingInErrorState extends AuthenticationState {
  const LoggingInErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

class LoggingOutState extends AuthenticationState {}

class LoggedOutState extends AuthenticationState {}

class LoggingOutErrorState extends AuthenticationState {
  const LoggingOutErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

class RefreshingTokenState extends AuthenticationState {}

class TokenRefreshedState extends AuthenticationState {}

class RefreshingTokenErrorState extends AuthenticationState {
  const RefreshingTokenErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

// Verify email
class VerifyingEmailState extends AuthenticationState {}

class EmailVerifiedState extends AuthenticationState {}

class VerifyingEmailErrorState extends AuthenticationState {
  const VerifyingEmailErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

// Send reset password link
class SendingResetPasswordLinkState extends AuthenticationState {}

class ResetPasswordLinkSentState extends AuthenticationState {
  const ResetPasswordLinkSentState({required this.message});

  final String message;

  List<Object> get props => [message];
}

class SendingResetPasswordLinkErrorState extends AuthenticationState {
  const SendingResetPasswordLinkErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

// Reset password
class ResettingPasswordState extends AuthenticationState {}

class PasswordResetState extends AuthenticationState {
  const PasswordResetState({required this.message});

  final String message;

  List<Object> get props => [message];
}

class ResettingPasswordErrorState extends AuthenticationState {
  const ResettingPasswordErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
