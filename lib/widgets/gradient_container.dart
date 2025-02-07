import 'package:flutter/material.dart';

import '../config/colors.dart';
import '../layout/device.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Device.width(context),
      height: Device.height(context),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        stops: [0.5, 0.9],
        colors: [
          kPrimaryDark,
          kTertiaryDark,
        ],
      )),
      child: child,
    );
  }
}
