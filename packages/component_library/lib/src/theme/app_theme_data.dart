import 'package:flutter/material.dart';

import 'catppuccin.dart';

// M3 default sizes + 2pt, Geist typeface.
const _textTheme = TextTheme(
  displayLarge: TextStyle(fontSize: 59),
  displayMedium: TextStyle(fontSize: 47),
  displaySmall: TextStyle(fontSize: 38),
  headlineLarge: TextStyle(fontSize: 34),
  headlineMedium: TextStyle(fontSize: 30),
  headlineSmall: TextStyle(fontSize: 26),
  titleLarge: TextStyle(fontSize: 24),
  titleMedium: TextStyle(fontSize: 18),
  titleSmall: TextStyle(fontSize: 16),
  bodyLarge: TextStyle(fontSize: 18),
  bodyMedium: TextStyle(fontSize: 16),
  bodySmall: TextStyle(fontSize: 14),
  labelLarge: TextStyle(fontSize: 16),
  labelMedium: TextStyle(fontSize: 14),
  labelSmall: TextStyle(fontSize: 13),
);

/// Abstract base class describing the app's theme.
///
/// Extend this class to add custom colors for new components:
/// ```dart
/// Color get noteCardBackgroundColor;
/// ```
/// Then implement the value in [LightAppThemeData] and [DarkAppThemeData].
abstract class AppThemeData {
  const AppThemeData();

  /// The Material [ThemeData] passed to [MaterialApp.theme] or [MaterialApp.darkTheme].
  ThemeData get materialThemeData;
}

/// Light variant of [AppThemeData] — Catppuccin Latte, Mauve accent.
final class LightAppThemeData extends AppThemeData {
  const LightAppThemeData();

  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Geist',
    textTheme: _textTheme,
    scaffoldBackgroundColor: CatppuccinLatte.base,
    colorScheme: const ColorScheme.light(
      primary: CatppuccinLatte.mauve,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEECDFF),
      onPrimaryContainer: CatppuccinLatte.mauve,
      secondary: CatppuccinLatte.lavender,
      onSecondary: Colors.white,
      surface: CatppuccinLatte.base,
      onSurface: CatppuccinLatte.text,
      onSurfaceVariant: CatppuccinLatte.subtext1,
      outline: CatppuccinLatte.overlay1,
      outlineVariant: CatppuccinLatte.surface1,
      error: CatppuccinLatte.red,
      onError: Colors.white,
      surfaceContainerHighest: CatppuccinLatte.surface0,
      surfaceContainerHigh: CatppuccinLatte.surface1,
      surfaceContainer: CatppuccinLatte.mantle,
      surfaceContainerLow: CatppuccinLatte.crust,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CatppuccinLatte.base,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      foregroundColor: CatppuccinLatte.text,
    ),
  );
}

/// Dark variant of [AppThemeData] — Catppuccin Frappé, Mauve accent.
final class DarkAppThemeData extends AppThemeData {
  const DarkAppThemeData();

  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Geist',
    textTheme: _textTheme,
    scaffoldBackgroundColor: CatppuccinFrappe.base,
    colorScheme: const ColorScheme.dark(
      primary: CatppuccinFrappe.mauve,
      onPrimary: CatppuccinFrappe.base,
      primaryContainer: CatppuccinFrappe.surface1,
      onPrimaryContainer: CatppuccinFrappe.mauve,
      secondary: CatppuccinFrappe.lavender,
      onSecondary: CatppuccinFrappe.base,
      surface: CatppuccinFrappe.base,
      onSurface: CatppuccinFrappe.text,
      onSurfaceVariant: CatppuccinFrappe.subtext1,
      outline: CatppuccinFrappe.overlay1,
      outlineVariant: CatppuccinFrappe.surface1,
      error: CatppuccinFrappe.red,
      onError: CatppuccinFrappe.base,
      surfaceContainerHighest: CatppuccinFrappe.surface0,
      surfaceContainerHigh: CatppuccinFrappe.surface1,
      surfaceContainer: CatppuccinFrappe.surface0,
      surfaceContainerLow: CatppuccinFrappe.mantle,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CatppuccinFrappe.base,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      foregroundColor: CatppuccinFrappe.text,
    ),
  );
}
