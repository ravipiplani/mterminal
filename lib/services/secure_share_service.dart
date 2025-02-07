import 'dart:async';

import 'package:dio/dio.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/exceptions/api_exception.dart';
import '../models/secure_share.dart';
import 'api_client.dart';

class SecureShareService {
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl, isTeamClient: true);

  Future<List<SecureShare>> get() async {
    try {
      final response = await _client.get(Endpoint.secureShares);
      final secureSharesData = response.data[Keys.results] as List;
      return secureSharesData.map((e) => SecureShare.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<SecureShare> create({required Map<String, dynamic> data}) async {
    try {
      final response = await _client.post(Endpoint.secureShares, data: data);
      final secureShareData = response.data as Map<String, dynamic>;
      return SecureShare.fromJson(secureShareData);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<SecureShare> update({required int secureShareId, required Map<String, dynamic> data}) async {
    try {
      final response = await _client.patch(Endpoint.secureShare.replaceAll(':id', secureShareId.toString()), data: data);
      final secureShareData = response.data as Map<String, dynamic>;
      return SecureShare.fromJson(secureShareData);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<void> delete({required int secureShareId}) async {
    try {
      await _client.delete(Endpoint.secureShare.replaceAll(':id', secureShareId.toString()));
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }
}
