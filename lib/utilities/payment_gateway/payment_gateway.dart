import 'package:flutter/material.dart';

import 'razorpay.dart';

enum PaymentGatewayType { razorpay }

abstract class PaymentGateway {
  factory PaymentGateway(
      {required BuildContext context,
      required PaymentGatewayType type,
      required String gatewayKey,
      required int amount,
      required String currency,
      required Function(String, String, String) onSuccess}) {
    switch (type) {
      case PaymentGatewayType.razorpay:
        return Razorpay(context: context, gatewayKey: gatewayKey, amount: amount, currency: currency, onSuccess: onSuccess);
      default:
        throw Exception('Invalid payment gateway type');
    }
  }

  void openGateway({required String token});
}
