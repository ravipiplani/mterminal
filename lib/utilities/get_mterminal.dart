import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../app_router.dart';
import '../config/constants.dart';
import '../config/keys.dart';
import '../models/alert.dart';
import '../models/license.dart';
import '../models/release_info.dart';
import '../models/team.dart';
import '../models/user.dart';
import '../services/credential_service.dart';
import 'helper.dart';
import 'preferences.dart';

class GetMterminal {
  GetMterminal._();

  static User user() {
    try {
      final userData = Preferences.getString(Keys.user);
      return User.fromJson(jsonDecode(userData));
    } on Exception {
      Helper.logOut();
      Get.offAllNamed(AppRouter.homePageRoute);
      throw Exception('Logged out. Bad user state found in app.');
    }
  }

  static Team selectedTeam() {
    try {
      final selectedTeamId = Preferences.getInt(Keys.selectedTeamId);
      return user().teams.firstWhere((team) => team.id == selectedTeamId);
    } on StateError {
      Helper.logOut();
      Get.offAllNamed(AppRouter.homePageRoute);
      throw Exception('Logged out. Bad team state found in app.');
    }
  }

  static License activeLicense() {
    try {
      return user().teams.firstWhere((element) => element.id == selectedTeam().id).activeLicense;
    } on StateError {
      Helper.logOut();
      Get.offAllNamed(AppRouter.homePageRoute);
      throw Exception('Logged out. Bad license state found in app.');
    }
  }

  static bool get isLightCustomer {
    final license = GetMterminal.activeLicense();
    return license.subscriptionPlan.costPerMonth == 0;
  }

  static void snackBar(BuildContext context, {required String content, ScaffoldMessengerState? state, SnackBarAction? action}) {
    state ??= ScaffoldMessenger.of(context);
    state.showSnackBar(SnackBar(content: Text(content), behavior: SnackBarBehavior.floating, showCloseIcon: true, action: action));
  }

  static Future<ReleaseInfo?> releaseInfo() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final latestVersions = jsonDecode(remoteConfig.getString(Keys.latestVersions)) as List;
    final releaseInfoData = latestVersions.where((element) => element['platform'] == defaultTargetPlatform.name).toList();

    if (releaseInfoData.isEmpty) {
      return null;
    }

    return ReleaseInfo.fromJson(releaseInfoData.first);
  }

  static List<Alert> alerts() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final alerts = jsonDecode(remoteConfig.getString(Keys.alerts)) as List;

    final a = alerts.map((e) => Alert.fromJson(e)).toList();
    return a.where((element) => element.expiryAt == null || element.expiryAt!.isAfter(DateTime.now())).toList();
  }

  static List comingSoon() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final comingSoon = jsonDecode(remoteConfig.getString(Keys.comingSoon)) as List;

    return comingSoon;
  }

  static Future<bool> exportCredentials() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final credentials = await CredentialService().get();
      final exportFileName = path.join(result, 'credentials.${kAppName.toLowerCase()}');
      final file = await File(exportFileName).create(exclusive: false);
      var content = [];
      for (final credential in credentials) {
        content.add(jsonEncode(credential.toJson()));
      }
      file.writeAsString(jsonEncode(content), mode: FileMode.write);
      return true;
    }
    return false;
  }
}
