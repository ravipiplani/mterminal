import 'package:flutter/material.dart';

import '../config/constants.dart';

class WidgetHelper {
  WidgetHelper._();

  static ButtonStyle get buttonStyleWhenLoading {
    return FilledButton.styleFrom(
        shape:
            const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(kButtonRadius), topRight: Radius.circular(kButtonRadius))));
  }
}
