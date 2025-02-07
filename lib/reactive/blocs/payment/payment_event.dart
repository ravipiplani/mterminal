part of 'payment_bloc.dart';

abstract class PaymentEvent {}

class UninitializedPaymentEvent extends PaymentEvent {}

class CreatePaymentOrderEvent extends PaymentEvent {
  CreatePaymentOrderEvent({this.invoiceId, required this.gateway, required this.subscriptionPlanId, required this.noOfSeats});

  final int gateway;
  final int subscriptionPlanId;
  final int noOfSeats;
  final int? invoiceId;

  List<Object> get props => [gateway, subscriptionPlanId, noOfSeats];
}

class CapturePaymentEvent extends PaymentEvent {
  CapturePaymentEvent({required this.transactionId, required this.data});

  final int transactionId;
  final Map<String, dynamic> data;

  List<Object> get props => [data];
}

class GetTransactionsEvent extends PaymentEvent {}

class RestorePurchaseEvent extends PaymentEvent {
  RestorePurchaseEvent({required this.productId, required this.purchaseId, required this.signature});

  final String productId;
  final String purchaseId;
  final String signature;

  List<Object> get props => [productId, purchaseId, signature];
}