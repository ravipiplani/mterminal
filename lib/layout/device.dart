import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../reactive/providers/app_provider.dart';
import 'responsive_builder.dart';

class Device extends StatelessWidget {
  const Device(
      {Key? key,
      this.mobile,
      this.screen,
      this.child,
      this.desktopMobileView,
      this.modalView = false,
      this.backgroundColor = Colors.transparent,
      this.addContainer = true,
      this.isBottomNavigationVisible = false})
      : super(key: key);

  final Widget? mobile;
  final Widget? child;
  final Widget? screen;
  final bool? modalView;
  final bool? desktopMobileView;
  final Color backgroundColor;
  final bool addContainer;
  final bool isBottomNavigationVisible;

  static const mobileWidth = 600.0;
  static const tabWidth = 1008.0;
  static const desktopWidth = 1200;
  static const kDesktopConstrainedWidth = 540.0;
  static const kMaxDesktopWidth = 1440.0;

  static double ratioMargin(context) => isDesktop(context) ? 0.1 : 0.2;

  static bool narrow(BuildContext context) => width(context) < mobileWidth;

  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static double width(BuildContext context) => MediaQuery.of(context).size.width;

  static int layout(BuildContext context) => narrow(context) ? kMobileColumns : kDesktopColumns;

  static double margin(BuildContext context) => grid(context) * ratioMargin(context);

  static double column(BuildContext context) => grid(context) * kRatioContent;

  static double grid(BuildContext context) => width(context) / layout(context);

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileWidth || MediaQuery.of(context).size.width < tabWidth;
  }

  static bool isTab(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileWidth && MediaQuery.of(context).size.width < tabWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopWidth;
  }

  static double dockMargin(BuildContext context) =>
      (margin(context) * 2) + (isDesktop(context) ? 0 : column(context)) + (context.watch<AppProvider>().isDockPinned && isDesktop(context) ? 160 : 60);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, size, widget) {
      if (isDesktop(context)) {
        return addContainer
            ? Align(
                alignment: Alignment.topCenter,
                child: Container(
                    clipBehavior: Clip.hardEdge,
                    margin: EdgeInsets.symmetric(vertical: Device.margin(context)),
                    height: _getHeight(context),
                    constraints: BoxConstraints(maxWidth: desktopMobileView == true ? kDesktopConstrainedWidth : width(context) * 0.8),
                    decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(kCardRadius)),
                    child: child))
            : child ?? Container();
      } else {
        return mobile ?? child ?? Container();
      }
    });
  }

  double? _getHeight(BuildContext context) {
    if (isBottomNavigationVisible) {
      return Device.height(context) - (kToolbarHeight * 2);
    }
    return null;
  }
}
