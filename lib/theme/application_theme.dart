import 'package:flutter/material.dart';
import 'package:rojgar/theme/input_decoration_theme.dart';

import 'button_navigation_theme.dart';

ThemeData getApplicationTheme() {
  const Color primaryColor = Color(0xFF43B925); // Rojgar Green

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,

    fontFamily: 'Poppins',

    // Themes
    inputDecorationTheme: getInputDecorationTheme(),
    bottomNavigationBarTheme: getBottomNavigationTheme(),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 3,
      centerTitle: true,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}
