import 'package:flutter/material.dart';

const _navy = Color(0xFF001F3F);
const _gold = Color(0xFFFFC857);
const _darkBg = Color(0xFF0B0C10);

ThemeData buildLightTheme() {
  final scheme = ColorScheme.light(
    primary: _navy,
    secondary: _gold,
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black87,
    onSurface: Colors.black87,
    onError: Colors.white,
  );
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: _navy,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
    useMaterial3: true,
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.dark(
    primary: _gold,
    secondary: _navy,
    surface: _darkBg,
    error: Colors.redAccent,
    onPrimary: Colors.black87,
    onSecondary: _gold,
    onSurface: Colors.white70,
    onError: Colors.black87,
  );
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: _darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF15171E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
    ),
    useMaterial3: true,
  );
}

