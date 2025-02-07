import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/constants.dart';
import '../models/host.dart';
import '../reactive/providers/app_provider.dart';
import '../services/credential_service.dart';
import '../services/host_service.dart';
import '../services/tag_service.dart';
import '../widgets/ssh_terminal.dart';
import 'analytics.dart';
import 'app_identifier.dart';
import 'get_mterminal.dart';
import 'preferences.dart';

class Helper {
  Helper._();

  static String get databaseFileName => '$kAppName.db';

  static Future<String> getDatabasePath() async {
    final databaseDirectory = await getApplicationSupportDirectory();
    return join(databaseDirectory.path, databaseFileName);
  }

  static Future<void> openUrl({required String url, LaunchMode mode = LaunchMode.externalApplication}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: mode);
    } else {
      throw 'Could not launch $url';
    }
  }

  static String enumToString(dynamic string) {
    return string.toString().split('.').last;
  }

  static dynamic stringToEnum(String enumeration, String string) {
    return null;
  }

  static String getInitials(String? userName) =>
      userName!.isNotEmpty ? userName.trim().replaceAll(RegExp(r'\s+'), ' ').split(' ').map((l) => l[0]).take(2).join().toUpperCase() : '';

  static void onTerminalExit(AppProvider appProvider, int index) {
    appProvider.selectedTerminal = null;
    appProvider.selectedNavigationRailIndex = 0;
    appProvider.activeTerminals.removeAt(index);
  }

  static bool _canConnectToHost({required AppProvider appProvider}) {
    final noOfRemoteActiveTerminals = appProvider.activeTerminals.where((sshTerminal) => sshTerminal.host != null).length;
    if (!appProvider.isLoggedIn) {
      return noOfRemoteActiveTerminals < 2;
    }
    return !GetMterminal.isLightCustomer || noOfRemoteActiveTerminals < 2;
  }

  static bool activateTerminal({required AppProvider appProvider, Host? host, String? terminalName}) {
    if (!_canConnectToHost(appProvider: appProvider)) {
      return false;
    }
    final key = appProvider.activeTerminals.length;
    int noOfActiveTerminalsOfSelectedHost = 0;
    String? name;
    if (host != null) {
      noOfActiveTerminalsOfSelectedHost =
          appProvider.activeTerminals.where((sshTerminal) => sshTerminal.host != null && sshTerminal.host!.id == host!.id).length;
      host = noOfActiveTerminalsOfSelectedHost == 0 ? host : host.copyWith(name: '${host.name} ($noOfActiveTerminalsOfSelectedHost)');
    } else {
      noOfActiveTerminalsOfSelectedHost = appProvider.activeTerminals
          .where((sshTerminal) => sshTerminal.host == null && (sshTerminal.name?.toLowerCase().startsWith(terminalName?.toLowerCase() ?? 'local') ?? false))
          .length;
      name = noOfActiveTerminalsOfSelectedHost == 0 ? 'Local' : 'Local ($noOfActiveTerminalsOfSelectedHost)';
    }
    appProvider.activeTerminals.add(SSHTerminal(
      key: ValueKey<int>(key),
      host: host,
      name: name,
      onExit: (index) {
        Helper.onTerminalExit(appProvider, index);
      },
    ));
    appProvider.selectedTerminal = key;
    appProvider.selectedNavigationRailIndex = null;
    appProvider.isDockPinned = true;
    appProvider.isDockHidden = true;
    return true;
  }

  static String displayAmount(int amount, {String? symbol = '₹', int decimalDigits = 2}) {
    final displayAmount = amount / 100;
    return NumberFormat.currency(locale: 'en_IN', decimalDigits: decimalDigits, symbol: symbol).format(displayAmount);
  }

  static Future<void> logOut({bool removeCredentials = false}) async {
    if (!kIsWeb) {
      await HostService().deleteAll();
      await TagService().deleteAll();
      if (removeCredentials) {
        await CredentialService().deleteAll();
      }
      await AppIdentifier.remove;
      await Analytics.reset();
    }
    await Preferences.clear();
  }

  static String? getHomeDirectoryPath() {
    String? home;
    final envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    return home;
  }

  static String generateSecurePassword({int length = 12}) {
    var a = '';
    var y = Iterable.generate(42, (int x) => 48 + x++).toList();
    for (int x = 1; x <= length; x++) {
      int r = Random().nextInt(y.length);
      int w = y[r];
      a += String.fromCharCode(w);
    }
    return a;
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) =>
      fold(<K, List<E>>{}, (map, element) => map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}
