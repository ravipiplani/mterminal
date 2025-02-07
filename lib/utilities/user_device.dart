import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../config/keys.dart';
import '../models/exceptions/cannot_add_device_exception.dart';
import '../models/exceptions/device_type_exists_exception.dart';
import '../services/app_device_service.dart';
import 'app_identifier.dart';
import 'preferences.dart';

class UserDevice {
  UserDevice._();

  static Future<void> update() async {
    final deviceData = await data();
    try {
      await AppDeviceService().update(data: deviceData);
      Preferences.setBool(Keys.cannotAddMoreDevices, false);
      Preferences.setBool(Keys.deviceTypeExists, false);
    } on CannotAddDeviceException {
      Preferences.setBool(Keys.cannotAddMoreDevices, true);
    } on DeviceTypeExistsException {
      Preferences.setBool(Keys.deviceTypeExists, true);
    }
  }

  static Future<Map<String, dynamic>> data() async {
    var deviceData = <String, dynamic>{};
    deviceData = await _info();
    final refresh = Preferences.getString(Keys.refreshToken);
    deviceData.addAll(
        {Keys.lastActiveAt: DateTime.now().toLocal().toIso8601String(), Keys.refresh: refresh, Keys.type: Platform.isIOS || Platform.isAndroid ? 2 : 1});
    return deviceData;
  }

  static Future<Map<String, dynamic>> _info() async {
    final deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> device = {};
    if (kIsWeb) {
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      device = {
        'browserName': webBrowserInfo.browserName.name,
        'appCodeName': webBrowserInfo.appCodeName,
        'appName': webBrowserInfo.appName,
        'appVersion': webBrowserInfo.appVersion,
        'deviceMemory': webBrowserInfo.deviceMemory,
        'language': webBrowserInfo.language,
        'languages': webBrowserInfo.languages,
        'platform': webBrowserInfo.platform,
        'product': webBrowserInfo.product,
        'productSub': webBrowserInfo.productSub,
        'userAgent': webBrowserInfo.userAgent,
        'vendor': webBrowserInfo.vendor,
        'vendorSub': webBrowserInfo.vendorSub,
        'hardwareConcurrency': webBrowserInfo.hardwareConcurrency,
        'maxTouchPoints': webBrowserInfo.maxTouchPoints,
        'identifier': AppIdentifier.id,
        'data': webBrowserInfo.data,
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = {'name': androidInfo.device, 'model': androidInfo.model, 'identifier': AppIdentifier.id, 'data': androidInfo.data};
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = {
        'model': iosInfo.model,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
        'systemVersion': iosInfo.systemVersion,
        'systemName': iosInfo.systemName,
        'identifierForVendor': iosInfo.identifierForVendor,
        'name': iosInfo.name,
        'localizedModel': iosInfo.localizedModel,
        'version': iosInfo.utsname.version,
        'release': iosInfo.utsname.release,
        'nodename': iosInfo.utsname.nodename,
        'machine': iosInfo.utsname.machine,
        'sysname': iosInfo.utsname.sysname,
        'identifier': AppIdentifier.id,
        'data': iosInfo.data
      };
    } else if (Platform.isMacOS) {
      final macOsInfo = await deviceInfo.macOsInfo;
      device = {
        'name': macOsInfo.computerName,
        'model': macOsInfo.model,
        'identifier': AppIdentifier.id,
        'data': macOsInfo.data,
      };
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      device = {
        'name': windowsInfo.computerName,
        'identifier': AppIdentifier.id,
        'data': windowsInfo.data,
      };
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      device = {
        'name': linuxInfo.name,
        'identifier': AppIdentifier.id,
        'data': linuxInfo.data,
      };
    }
    return device;
  }
}
