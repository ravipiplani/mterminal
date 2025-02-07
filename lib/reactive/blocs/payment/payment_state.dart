part of 'payment_bloc.dart';

abstract class PaymentState {
  PaymentState();
}

class UninitializedState extends PaymentState {}

//Initiate Payment
class CreatingPaymentOrderState extends PaymentState {}

class PaymentOrderCreatedState extends PaymentState {
  PaymentOrderCreatedState({required this.paymentOrder});

  final PaymentOrder paymentOrder;

  List<Object> get props => [paymentOrder];
}

class CreatingPaymentOrderErrorState extends PaymentState {
  CreatingPaymentOrderErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Verify Payment
class CapturingPaymentState extends PaymentState {}

class PaymentCapturedState extends PaymentState {}

class CapturingPaymentErrorState extends PaymentState {
  CapturingPaymentErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Verify Payment
class RestoringPurchaseState extends PaymentState {}

class PurchaseRestoredState extends PaymentState {}

class RestoringPurchaseErrorState extends PaymentState {
  RestoringPurchaseErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
