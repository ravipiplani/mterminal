import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/exceptions/api_exception.dart';
import '../models/user.dart';
import '../utilities/get_mterminal.dart';
import '../utilities/preferences.dart';
import 'api_client.dart';

class UserService {
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl);

  Future<User> me() async {
    try {
      final response = await _client.get(Endpoint.me);
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data);
      await Preferences.setString(Keys.user, jsonEncode(data));
      if (Preferences.getInt(Keys.selectedTeamId) == null) {
        await Preferences.setInt(Keys.selectedTeamId, user.teams.first.id);
      }
      return User.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<void> changePassword({required int userId, required Map<String, dynamic> data}) async {
    try {
      await _client.post(Endpoint.changePassword.replaceAll(':id', userId.toString()), data: data);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<void> changeEmail({required int userId, required Map<String, dynamic> data}) async {
    try {
      await _client.post(Endpoint.changeEmail.replaceAll(':id', userId.toString()), data: data);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<void> resendVerificationLink({required int userId}) async {
    try {
      await _client.post(Endpoint.resendVerificationLink.replaceAll(':id', userId.toString()));
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<List<Map<String, dynamic>>> roles() async {
    try {
      final response = await _client.get(Endpoint.roles);
      final data = response.data as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<String> deleteAccount({required String password}) async {
    try {
      final response = await _client.post(Endpoint.deleteAccount.replaceAll(':id', GetMterminal.user().id.toString()), data: {Keys.password: password});
      final responseData = response.data as Map<String, dynamic>;
      return responseData[Keys.message];
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }
}
