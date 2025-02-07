part of 'credential_bloc.dart';

abstract class CredentialEvent {}

class UninitializedEvent extends CredentialEvent {}

class GetCredentialsEvent extends CredentialEvent {
  GetCredentialsEvent({this.includeDeleted = false});

  final bool includeDeleted;

  List<Object> get props => [includeDeleted];
}
