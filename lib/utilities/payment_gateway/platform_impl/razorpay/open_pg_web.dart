// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../app_router.dart';

void openPG(BuildContext context, Razorpay razorpay, Map<String, dynamic> options, Function(String, String, String)? onSuccess) {
  final optionsStr = jsonEncode(options);
  js.context['razorpayCallback'] = onSuccess;
  js.context['razorpayModalDismissed'] = () {
    Get.offNamed(AppRouter.paymentFailurePageRoute);
  };
  js.context.callMethod('openRazorpay', [optionsStr]);
}
