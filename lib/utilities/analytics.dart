import 'dart:async' show Future;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/keys.dart';
import '../models/user.dart';

mixin Analytics {
  static final instance = FirebaseAnalytics.instance;

  static Future<void> initialize() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!kIsWeb) {
      instance.setDefaultEventParameters({
        Keys.version: packageInfo.version,
        Keys.buildNumber: packageInfo.buildNumber,
      });
    }
    await instance.logAppOpen();
  }

  static Future<void> logSignUp() async {
    await instance.logSignUp(signUpMethod: 'email');
  }

  static Future<void> logLogin() async {
    await instance.logLogin(loginMethod: 'email');
  }

  static Future<void> reset() async {
    await instance.resetAnalyticsData();
  }

  static Future<void> setUser({required User user}) async {
    await instance.setUserId(id: user.id.toString());
    await instance.setUserProperty(name: Keys.name, value: '${user.firstName} ${user.lastName}');
    await instance.setUserProperty(name: Keys.email, value: user.email);
  }

  static Future<void> logButton({required String name}) async {
    await instance.logEvent(name: 'button', parameters: {Keys.name: name});
  }
}
