part of 'credential_bloc.dart';

abstract class CredentialState {
  CredentialState();
}

class UninitializedState extends CredentialState {}

//Retrieving Credentials
class RetrieveCredentialsState extends CredentialState {}

class CredentialsRetrievedState extends CredentialState {
  CredentialsRetrievedState({required this.credentials});

  final List<Credential> credentials;

  List<Object> get props => [credentials];
}

class RetrieveCredentialsErrorState extends CredentialState {
  RetrieveCredentialsErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
