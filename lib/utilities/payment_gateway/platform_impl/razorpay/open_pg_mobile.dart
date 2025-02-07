import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void openPG(BuildContext context, Razorpay razorpay, Map<String, dynamic> options, Function(String, String, String)? onSuccess) {
  razorpay.open(options);
}
