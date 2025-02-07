import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_router.dart';
import '../config/endpoint.dart';

class MTerminalBottomAppBar extends StatefulWidget {
  const MTerminalBottomAppBar({super.key});

  @override
  State<MTerminalBottomAppBar> createState() => _MTerminalBottomAppBarState();
}

class _MTerminalBottomAppBarState extends State<MTerminalBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (kIsWeb) {
                launchUrl(
                  Uri.parse(Endpoint.website),
                  webOnlyWindowName: '_self',
                );
              }
              else {
                Get.offAllNamed(AppRouter.homePageRoute);
              }
            },
            icon: const Icon(Icons.home),
          )
        ],
      ),
    );
  }
}
