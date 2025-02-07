part of 'user_bloc.dart';

abstract class UserEvent {}

class UninitializedEvent extends UserEvent {}

class GetUserEvent extends UserEvent {}

class ChangePasswordEvent extends UserEvent {
  ChangePasswordEvent({required this.userId, required this.data});

  final int userId;
  final Map<String, dynamic> data;

  List<Object> get props => [userId, data];
}

class ChangeEmailEvent extends UserEvent {
  ChangeEmailEvent({required this.userId, required this.data});

  final int userId;
  final Map<String, dynamic> data;

  List<Object> get props => [userId, data];
}

class ResendEmailVerificationLinkEvent extends UserEvent {
  ResendEmailVerificationLinkEvent({required this.userId});

  final int userId;

  List<Object> get props => [userId];
}

class DeleteAccountEvent extends UserEvent {
  DeleteAccountEvent({required this.password});

  final String password;

  List<Object> get props => [password];
}
