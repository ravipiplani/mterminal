import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_router.dart';
import '../config/constants.dart';
import '../config/images.dart';
import '../reactive/providers/app_provider.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.redirectToWebsite = false, this.onlyIcon = false, this.logoHeight = 24});

  final bool redirectToWebsite;
  final bool onlyIcon;
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _onTap(context);
        },
        child: onlyIcon
            ? Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: const BorderRadius.all(Radius.circular(kCardRadius))),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: const Image(
                  image: AssetImage(Images.icon),
                  height: 32,
                  color: Colors.white,
                ),
              )
            : Image(
                image: const AssetImage(Images.logo),
                height: logoHeight,
              ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (redirectToWebsite) {
      launchUrl(
        Uri.parse('https://mterminal.app'),
        webOnlyWindowName: '_self',
      );
    } else {
      context.read<AppProvider>().selectedTool = 'home';
      context.read<AppProvider>().isDockHidden = false;
      context.read<AppProvider>().isDockCollapsed = false;
      Get.offAllNamed(AppRouter.homePageRoute);
    }
  }
}
