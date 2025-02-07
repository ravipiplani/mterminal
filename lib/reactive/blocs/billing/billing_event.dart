part of 'billing_bloc.dart';

abstract class BillingEvent {}

class UninitializedEvent extends BillingEvent {}

class GetInvoicesEvent extends BillingEvent {}
