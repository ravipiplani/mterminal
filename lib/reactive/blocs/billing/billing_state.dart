part of 'billing_bloc.dart';

abstract class BillingState {
  BillingState();
}

class UninitializedState extends BillingState {}

//Retrieving Invoices
class RetrievingInvoicesState extends BillingState {}

class InvoicesRetrievedState extends BillingState {
  InvoicesRetrievedState({required this.invoices});

  final List<Invoice> invoices;

  List<Object> get props => [invoices];
}

class RetrievingInvoicesErrorState extends BillingState {
  RetrievingInvoicesErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
