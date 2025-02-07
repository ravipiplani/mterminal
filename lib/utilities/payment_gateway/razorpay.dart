import 'package:flutter/cupertino.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as rp;

import '../get_mterminal.dart';
import 'payment_gateway.dart';
import 'platform_impl/razorpay/open_pg_stub.dart'
    if (dart.library.io) 'platform_impl/razorpay/open_pg_mobile.dart'
    if (dart.library.js) 'platform_impl/razorpay/open_pg_web.dart';

class Razorpay implements PaymentGateway {
  Razorpay({required this.amount, required this.currency, required this.context, required this.gatewayKey, required this.onSuccess}) {
    _razorpay.on(rp.Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(rp.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  final String gatewayKey;
  final BuildContext context;
  final int amount;
  final String currency;
  final Function(String, String, String) onSuccess;

  final _razorpay = rp.Razorpay();

  @override
  void openGateway({required String token}) {
    final user = GetMterminal.user();
    final options = {
      'key': gatewayKey,
      'amount': amount,
      'currency': currency,
      'order_id': token,
      'prefill': {'name': user.firstName, 'email': user.email},
      'modal': {}
    };
    openPG(context, _razorpay, options, onSuccess);
  }

  void _handlePaymentSuccess(rp.PaymentSuccessResponse response) {}

  void _handlePaymentError(rp.PaymentFailureResponse response) {}
}
