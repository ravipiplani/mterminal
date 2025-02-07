part of 'user_bloc.dart';

abstract class UserState {
  UserState();
}

class UninitializedState extends UserState {}

//Retrieving User
class RetrievingUserState extends UserState {}

class UserRetrievedState extends UserState {
  UserRetrievedState({required this.user});

  final User user;

  List<Object> get props => [user];
}

class RetrievingUserErrorState extends UserState {
  RetrievingUserErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Change password
class ChangingPasswordState extends UserState {}

class PasswordChangedState extends UserState {}

class ChangingPasswordErrorState extends UserState {
  ChangingPasswordErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Change email
class ChangingEmailState extends UserState {}

class EmailChangedState extends UserState {}

class ChangingEmailErrorState extends UserState {
  ChangingEmailErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Resend email verification link
class ResendingEmailVerificationLinkState extends UserState {}

class EmailVerificationLinkResentState extends UserState {}

class ResendingEmailVerificationLinkErrorState extends UserState {
  ResendingEmailVerificationLinkErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Delete Account
class DeletingAccountState extends UserState {}

class AccountDeletedState extends UserState {
  AccountDeletedState({required this.message});

  final String message;

  List<Object> get props => [message];
}

class DeletingAccountErrorState extends UserState {
  DeletingAccountErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
