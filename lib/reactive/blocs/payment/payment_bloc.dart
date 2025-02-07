import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../models/payment_order.dart';
import '../../../services/payment_service.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(UninitializedState()) {
    on<UninitializedPaymentEvent>(_onUninitializedPaymentEvento);
    on<CreatePaymentOrderEvent>(_onInitiatePaymentEvent);
    on<CapturePaymentEvent>(_onVerifyPaymentEvent);
    on<RestorePurchaseEvent>(_onRestorePurchaseEvent);
  }

  final _paymentService = PaymentService();

  PaymentState get initialState => UninitializedState();

  Future<void> _onUninitializedPaymentEvento(UninitializedPaymentEvent event, Emitter<PaymentState> emit) async {
    emit(UninitializedState());
  }

  Future<void> _onInitiatePaymentEvent(CreatePaymentOrderEvent event, Emitter<PaymentState> emit) async {
    emit(CreatingPaymentOrderState());
    try {
      final paymentOrder = await _paymentService.createOrder(
          gateway: event.gateway, subscriptionPlanId: event.subscriptionPlanId, invoiceId: event.invoiceId, noOfSeats: event.noOfSeats);
      emit(PaymentOrderCreatedState(paymentOrder: paymentOrder));
    } on Exception catch (e) {
      emit(CreatingPaymentOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _onVerifyPaymentEvent(CapturePaymentEvent event, Emitter<PaymentState> emit) async {
    emit(CapturingPaymentState());
    try {
      await _paymentService.capturePayment(transactionId: event.transactionId, data: event.data);
      emit(PaymentCapturedState());
    } on Exception catch (e) {
      emit(CapturingPaymentErrorState(message: e.toString()));
    }
  }

  Future<void> _onRestorePurchaseEvent(RestorePurchaseEvent event, Emitter<PaymentState> emit) async {
    emit(RestoringPurchaseState());
    try {
      await _paymentService.restorePurchase(productId: event.productId, purchaseId: event.purchaseId, signature: event.signature);
      emit(PurchaseRestoredState());
    } on Exception catch (e) {
      emit(RestoringPurchaseErrorState(message: e.toString()));
    }
  }
}
