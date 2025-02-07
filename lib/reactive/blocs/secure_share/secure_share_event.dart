part of 'secure_share_bloc.dart';

abstract class SecureShareEvent {}

class UninitializedEvent extends SecureShareEvent {}

class GetSecureSharesEvent extends SecureShareEvent {}

class CreateSecureShareEvent extends SecureShareEvent {
  CreateSecureShareEvent({required this.data});

  final Map<String, dynamic> data;

  List<Object> get props => [data];
}

class DeleteSecureShareEvent extends SecureShareEvent {
  DeleteSecureShareEvent({required this.secureShareId});

  final int secureShareId;

  List<Object> get props => [secureShareId];
}

class UpdateSecureShareEvent extends SecureShareEvent {
  UpdateSecureShareEvent({required this.secureShareId, required this.data});

  final int secureShareId;
  final Map<String, dynamic> data;

  List<Object> get props => [secureShareId, data];
}
