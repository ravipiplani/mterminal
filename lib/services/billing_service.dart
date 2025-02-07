import 'dart:async';

import 'package:dio/dio.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/exceptions/api_exception.dart';
import '../models/invoice.dart';
import 'api_client.dart';

class BillingService {
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl, isTeamClient: true);

  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await _client.get(Endpoint.invoices);
      final invoicesData = response.data[Keys.results] as List;
      return invoicesData.map((e) => Invoice.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }
}
