import 'package:flutter/material.dart';

import '../../layout/device.dart';

class InstallerView extends StatelessWidget {
  const InstallerView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Device.margin(context)),
      child: Center(
        child: Device(
          desktopMobileView: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Download App',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Device.margin(context)),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
