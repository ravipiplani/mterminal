import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../layout/device.dart';

class StatusView extends StatelessWidget {
  const StatusView({super.key, required this.lottie, required this.title, this.description, this.buttonText, this.onPressed});

  final String lottie;
  final String title;
  final String? description;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final btnText = buttonText ?? 'click here';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(lottie, width: Device.grid(context) * 2, repeat: false),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (description != null)
            Device(
                desktopMobileView: true,
                child: Text(
                  description!,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                )),
          SizedBox(height: Device.margin(context) * 2),
          if (onPressed != null) FilledButton(onPressed: onPressed, child: Text(btnText.toUpperCase()))
        ],
      ),
    );
  }
}
