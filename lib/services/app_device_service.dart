import 'dart:async';

import 'package:dio/dio.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/app_device.dart';
import '../models/exceptions/api_exception.dart';
import '../models/exceptions/cannot_add_device_exception.dart';
import '../models/exceptions/device_type_exists_exception.dart';
import 'api_client.dart';

class AppDeviceService {
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl, isTeamClient: true);

  Future<List<AppDevice>> get() async {
    try {
      final response = await _client.get(Endpoint.devices);
      final devicesData = response.data[Keys.results] as List;
      return devicesData.map((e) => AppDevice.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<AppDevice> update({required Map<String, dynamic> data}) async {
    try {
      final response = await _client.post(Endpoint.devicesUpdate, data: data);
      final deviceData = response.data as Map<String, dynamic>;
      return AppDevice.fromJson(deviceData);
    } on DioException catch (e) {
      if (e.message == Keys.cannotAddMoreDevices) {
        throw CannotAddDeviceException();
      } else if (e.message == Keys.deviceTypeExists) {
        throw DeviceTypeExistsException();
      } else {
        throw ApiException(e.message);
      }
    }
  }
}
