import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../models/invoice.dart';
import '../../../services/billing_service.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  BillingBloc() : super(UninitializedState()) {
    on<GetInvoicesEvent>(_onGetInvoicesEvent);
  }

  final _billingService = BillingService();

  BillingState get initialState => UninitializedState();

  Future<void> _onGetInvoicesEvent(GetInvoicesEvent event, Emitter<BillingState> emit) async {
    emit(RetrievingInvoicesState());
    try {
      final invoices = await _billingService.getInvoices();
      emit(InvoicesRetrievedState(invoices: invoices));
    } on Exception catch (e) {
      emit(RetrievingInvoicesErrorState(message: e.toString()));
    }
  }
}
