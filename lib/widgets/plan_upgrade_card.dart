import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../app_router.dart';
import '../config/endpoint.dart';
import '../config/keys.dart';
import '../layout/device.dart';
import '../reactive/providers/app_provider.dart';
import '../utilities/analytics.dart';
import '../utilities/get_mterminal.dart';
import '../utilities/helper.dart';
import '../utilities/preferences.dart';
import 'dialogs/pricing_redirection_dialog.dart';
import 'title_card.dart';

class PlanUpgradeCard extends StatefulWidget {
  const PlanUpgradeCard({super.key});

  @override
  State<PlanUpgradeCard> createState() => _PlanUpgradeCardState();
}

class _PlanUpgradeCardState extends State<PlanUpgradeCard> {
  late AppProvider _readAppProvider;
  late bool _isUpgradeAvailable;

  @override
  void initState() {
    _readAppProvider = context.read<AppProvider>();
    _isUpgradeAvailable = _readAppProvider.isLoggedIn && GetMterminal.activeLicense().subscriptionPlan.costPerMonth == 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isUpgradeAvailable
        ? Padding(
            padding: EdgeInsets.all(Device.margin(context)),
            child: TitleCard(
                color: Colors.transparent,
                title: 'UPGRADE',
                desc: 'For Infrastructure Pros: 24/7 Excellence in Your Hands',
                isDark: true,
                child: ElevatedButton(
                  onPressed: () {
                    upgradePlan(context);
                  },
                  child: const Text('UPGRADE'),
                )),
          )
        : const SizedBox();
  }
}

void upgradePlan(BuildContext context) {
  Analytics.logButton(name: 'Upgrade');
  if (kIsWeb || Platform.isMacOS || Platform.isIOS) {
    Get.toNamed(AppRouter.pricingPageRoute);
  }
  else {
    showPricingRedirectionDialog(context);
    final uri = Uri.http(Endpoint.app, AppRouter.authAutoLoginPageRoute,
        {Keys.refresh: Preferences.getString(Keys.refreshToken), Keys.redirectTo: AppRouter.pricingPageRoute});
    Helper.openUrl(url: uri.toString());
  }
}
