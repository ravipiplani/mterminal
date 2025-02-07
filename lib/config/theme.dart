import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_schemes.g.dart';
import 'colors.dart';
import 'constants.dart';

final ThemeData kLightTheme = _buildLightTheme();
final ThemeData kDarkTheme = _buildDarkTheme();

ThemeData _buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true).copyWith(colorScheme: lightColorScheme, textTheme: GoogleFonts.baloo2TextTheme());
  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(color: Colors.transparent, elevation: 0),
    tabBarTheme: base.tabBarTheme.copyWith(
      labelPadding: const EdgeInsets.symmetric(vertical: kPadding * 2),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    inputDecorationTheme: base.inputDecorationTheme.copyWith(border: const OutlineInputBorder()),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData.dark(useMaterial3: true).copyWith(colorScheme: darkColorScheme, primaryColor: kPrimaryDark, textTheme: GoogleFonts.baloo2TextTheme());
}
