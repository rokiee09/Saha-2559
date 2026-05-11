import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'police_colors.dart';

ThemeData _baseTheme(ThemeData base, {required bool isDark}) {
  return base.copyWith(
    splashFactory: InkSplash.splashFactory,
  );
}

ThemeData buildLightTheme() {
  const navy = PoliceColors.navy;
  const gold = PoliceColors.gold;

  final scheme = ColorScheme.light(
    primary: navy,
    onPrimary: Colors.white,
    primaryContainer: Color.lerp(navy, Colors.white, 0.88)!,
    onPrimaryContainer: navy,
    secondary: gold.withValues(alpha: 0.9),
    onSecondary: PoliceColors.navy,
    surface: PoliceColors.surfaceLight,
    onSurface: PoliceColors.onSurfaceLight,
    onSurfaceVariant: Color(0xFF5C6570),
    error: const Color(0xFF8B2E2E),
    onError: Colors.white,
    outline: Color(0xFFCBD1DA),
    outlineVariant: Color(0xFFE1E5EC),
  );

  var light = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: Border(
          bottom: BorderSide(color: outlineLine(isDark: false), width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: navy.withValues(alpha: 0.55), width: 1.5),
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.75)),
        isDense: true,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        height: 64,
        indicatorColor: navy.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? navy : const Color(0xFF6B7280),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? navy : const Color(0xFF6B7280),
          ),
        ),
      ),
  );

  light = light.copyWith(
    textTheme: light.textTheme.copyWith(
      bodyLarge: light.textTheme.bodyLarge?.copyWith(height: 1.52, letterSpacing: 0.15),
      bodyMedium: light.textTheme.bodyMedium?.copyWith(height: 1.42),
      titleMedium: light.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onInverseSurface, height: 1.35),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minVerticalPadding: 12,
    ),
  );

  return _baseTheme(light, isDark: false);
}

Color outlineLine({required bool isDark}) {
  return isDark
      ? PoliceColors.outlineMuted.withValues(alpha: 0.4)
      : const Color(0xFFE0E4EB);
}

ThemeData buildDarkTheme() {
  const navy = PoliceColors.navy;
  const gold = PoliceColors.gold;
  const bg = PoliceColors.backgroundDark;
  const surface = PoliceColors.surfaceDark;

  final scheme = ColorScheme.dark(
    primary: Color(0xFF5B7AAD),
    onPrimary: Color(0xFF0A1020),
    primaryContainer: navy,
    onPrimaryContainer: Color(0xFFE8ECF5),
    secondary: gold,
    onSecondary: Color(0xFF1A1A12),
    surface: surface,
    onSurface: Color(0xFFE8EDF4),
    onSurfaceVariant: PoliceColors.onDarkMuted,
    error: const Color(0xFFCF6B6B),
    onError: Color(0xFF1A0A0A),
    outline: PoliceColors.outlineMuted.withValues(alpha: 0.5),
    outlineVariant: PoliceColors.outlineMuted.withValues(alpha: 0.3),
  );

  var dark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: PoliceColors.navy,
        foregroundColor: const Color(0xFFE8EDF4),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE8EDF4),
        ),
        shape: Border(
          bottom: BorderSide(
            color: gold.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      cardTheme: CardThemeData(
        color: PoliceColors.surfaceDarkElevated,
        elevation: 2.5,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.75),
            width: 1,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PoliceColors.surfaceDarkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.45), width: 1.2),
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        isDense: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PoliceColors.surfaceDark,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.55),
        height: 64,
        indicatorColor: gold.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? const Color(0xFFE0E0E0) : PoliceColors.onDarkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? const Color(0xFFE8EDF4) : PoliceColors.onDarkMuted,
          ),
        ),
      ),
  );

  dark = dark.copyWith(
    textTheme: dark.textTheme.copyWith(
      bodyLarge: dark.textTheme.bodyLarge?.copyWith(height: 1.55, letterSpacing: 0.15),
      bodyMedium: dark.textTheme.bodyMedium?.copyWith(height: 1.45),
      titleMedium: dark.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: PoliceColors.surfaceDarkElevated,
      contentTextStyle: TextStyle(
        color: PoliceColors.titleOnDark,
        height: 1.38,
        fontSize: 14,
      ),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      actionTextColor: PoliceColors.primaryBlue,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minVerticalPadding: 12,
    ),
  );

  return _baseTheme(dark, isDark: true);
}
