import 'dart:async';

import 'package:dio/dio.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/exceptions/api_exception.dart';
import '../utilities/helper.dart';
import '../utilities/mterminal_sync.dart';
import '../utilities/preferences.dart';
import 'api_client.dart';
import 'user_service.dart';

class AuthenticationService {
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl);

  Future<bool> signUp({required Map<String, dynamic> data}) async {
    try {
      await _client.post(Endpoint.authSignUp, data: data);
      return true;
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<bool> logIn({required String email, required String password}) async {
    try {
      final response = await _client.post(Endpoint.authLogIn, data: {Keys.email: email, Keys.password: password});

      // set access tokens
      final data = response.data as Map<String, dynamic>;
      await Preferences.setString(Keys.accessToken, data[Keys.access]);
      await Preferences.setString(Keys.refreshToken, data[Keys.refresh]);

      // get user
      await UserService().me();

      // sync user data
      await MTerminalSync.start;
      return true;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        throw ApiException('Invalid email or password.');
      }
      throw ApiException(e.message);
    }
  }

  Future<bool> logOut({String? token}) async {
    try {
      await MTerminalSync.start;
      await _client.post(Endpoint.authLogOut, data: {Keys.refresh: token ?? Preferences.getString(Keys.refreshToken)});
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> refresh({required String refresh}) async {
    try {
      final response = await _client.post(Endpoint.authRefresh, data: {Keys.refresh: refresh});
      final data = response.data as Map<String, dynamic>;
      await Preferences.setString(Keys.accessToken, data[Keys.access]);
      await UserService().me();
      await MTerminalSync.start;
      return true;
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<bool> verifyEmail({required String uid, required String token}) async {
    try {
      await _client.post(Endpoint.authVerifyEmail, data: {Keys.uid: uid, Keys.token: token});
      return true;
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<String> sendResetPasswordLink({required String email}) async {
    try {
      final response = await _client.post(Endpoint.authSendResetPasswordLink, data: {Keys.email: email});
      final data = response.data as Map<String, dynamic>;
      return data[Keys.message];
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<String> resetPassword({required String uid, required String token, required String password}) async {
    try {
      final response = await _client.post(Endpoint.authResetPassword, data: {Keys.uid: uid, Keys.token: token, Keys.password: password});
      final data = response.data as Map<String, dynamic>;
      return data[Keys.message];
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }
}
