part of 'secure_share_bloc.dart';

abstract class SecureShareState {
  SecureShareState();
}

class UninitializedState extends SecureShareState {}

//Retrieve Secure Shares
class RetrievingSecureSharesState extends SecureShareState {}

class SecureSharesRetrievedState extends SecureShareState {
  SecureSharesRetrievedState({required this.secureShares});

  final List<SecureShare> secureShares;

  List<Object> get props => [secureShares];
}

class RetrievingSecureSharesErrorState extends SecureShareState {
  RetrievingSecureSharesErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Create Secure Share
class CreatingSecureShareState extends SecureShareState {}

class SecureShareCreatedState extends SecureShareState {
  SecureShareCreatedState({required this.secureShare});

  final SecureShare secureShare;

  List<Object> get props => [secureShare];
}

class CreatingSecureShareErrorState extends SecureShareState {
  CreatingSecureShareErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Delete Secure Share
class DeletingSecureShareState extends SecureShareState {}

class SecureShareDeletedState extends SecureShareState {}

class DeletingSecureShareErrorState extends SecureShareState {
  DeletingSecureShareErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Update Secure Share
class UpdatingSecureShareState extends SecureShareState {}

class SecureShareUpdatedState extends SecureShareState {
  SecureShareUpdatedState({required this.secureShare});

  final SecureShare secureShare;

  List<Object> get props => [secureShare];
}

class UpdatingSecureShareErrorState extends SecureShareState {
  UpdatingSecureShareErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
