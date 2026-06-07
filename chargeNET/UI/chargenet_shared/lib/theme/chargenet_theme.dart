import 'package:flutter/material.dart';

import 'chargenet_colors.dart';

/// Builds [ThemeData] for ChargeNET mobile and desktop shells.
abstract final class ChargeNetTheme {
  /// Bottom sheets, full-bleed map — tighter radius and padding.
  static ThemeData mobile() => _build(isDesktop: false);

  /// Sidebar layout, data tables — wider radius and padding.
  static ThemeData desktop() => _build(isDesktop: true);

  static ThemeData _build({required bool isDesktop}) {
    final cardRadius = isDesktop ? 16.0 : 12.0;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ChargeNetColors.background,
      colorScheme: const ColorScheme.dark(
        surface: ChargeNetColors.surface,
        primary: ChargeNetColors.primary,
        onPrimary: ChargeNetColors.textPrimary,
        onSurface: ChargeNetColors.textPrimary,
        secondary: ChargeNetColors.textSecondary,
        error: ChargeNetColors.warning,
        outline: ChargeNetColors.surfaceElevated,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ChargeNetColors.background,
        foregroundColor: ChargeNetColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: ChargeNetColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ChargeNetColors.surfaceElevated,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: ChargeNetColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: ChargeNetColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: ChargeNetColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: ChargeNetColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: ChargeNetColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ChargeNetColors.primary,
        foregroundColor: ChargeNetColors.textPrimary,
      ),
    );
  }
}
