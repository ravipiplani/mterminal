import 'package:dio/dio.dart';

import '../config/keys.dart';
import '../utilities/preferences.dart';

class ApiClient {
  Dio init({required String baseUrl, bool isTeamClient = false}) {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    final interceptors = [AppInterceptor(), if (isTeamClient) TeamInterceptor(), LogInterceptor(requestBody: true, responseBody: true)];
    dio.interceptors.addAll(interceptors);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    return dio;
  }
}

class TeamInterceptor extends QueuedInterceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({Keys.teamId: Preferences.getInt(Keys.selectedTeamId)});
    handler.next(options);
  }
}

class AppInterceptor extends QueuedInterceptor {
  final _customExceptionHandlingFields = [Keys.cannotAddMoreDevices, Keys.deviceTypeExists];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      //Auth Token
      if (Preferences.getString(Keys.accessToken).isNotEmpty) {
        options.headers.addAll({'Authorization': 'Bearer ${Preferences.getString(Keys.accessToken)}'});
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      if (err.response!.statusCode == 403) {
        try {
          Preferences.remove(Keys.accessToken);
          Preferences.remove(Keys.refreshToken);
        } on Exception {
          // do nothing
        }
      } else if ([400, 401].contains(err.response!.statusCode)) {
        final data = err.response!.data;
        String? message;
        if (data is Map) {
          if (data.containsKey('message')) {
            message = data['message'];
          } else if (data.containsKey('detail')) {
            message = data['detail'];
          } else {
            final messageList = [];
            if ((data as Map<String, dynamic>).keys.any((key) => _customExceptionHandlingFields.contains(key))) {
              _customExceptionHandler(data, err, handler);
              return;
            } else {
              data.forEach((key, value) {
                messageList.add(value is List ? value[0] : value);
              });
              message = messageList.join(', ');
            }
          }
        }
        handler.next(DioException(requestOptions: err.requestOptions, message: message));
        return;
      }
    }
    handler.next(err);
  }

  void _customExceptionHandler(Map<String, dynamic> data, DioException err, ErrorInterceptorHandler handler) {
    for (final key in data.keys) {
      if (_customExceptionHandlingFields.contains(key)) {
        handler.next(DioException(requestOptions: err.requestOptions, message: key));
        break;
      }
    }
  }
}
