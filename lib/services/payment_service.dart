import 'dart:async';

import 'package:dio/dio.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/exceptions/api_exception.dart';
import '../models/payment_order.dart';
import 'api_client.dart';

class PaymentService {
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl, isTeamClient: true);

  Future<PaymentOrder> createOrder({required int gateway, required int subscriptionPlanId, required int noOfSeats, int? invoiceId}) async {
    try {
      final response = await _client.post(Endpoint.transactionsCreateOrder,
          data: {Keys.gateway: gateway, Keys.subscriptionPlanId: subscriptionPlanId, Keys.invoiceId: invoiceId, Keys.noOfSeats: noOfSeats});
      return PaymentOrder.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<void> capturePayment({required int transactionId, required Map<String, dynamic> data}) async {
    try {
      await _client.post(Endpoint.transactionsCapture.replaceAll(':id', transactionId.toString()), data: data);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<void> restorePurchase({required String productId, required String purchaseId, required String signature}) async {
    try {
      await _client.post(Endpoint.transactionsRestorePurchase, data: {
        Keys.productId: productId,
        Keys.purchaseId: purchaseId,
        Keys.signature: signature
      });
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }
}
