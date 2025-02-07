import 'dart:async';

import 'package:dio/dio.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/exceptions/api_exception.dart';
import '../models/subscription_plan.dart';
import 'api_client.dart';

class SubscriptionPlanService {
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl);

  Future<List<SubscriptionPlan>> get() async {
    try {
      final response = await _client.get(Endpoint.subscriptionPlans);
      final subscriptionPlansData = response.data[Keys.results] as List;
      return subscriptionPlansData.map((e) => SubscriptionPlan.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }
}
