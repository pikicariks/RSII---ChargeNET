import 'package:flutter/material.dart';

import 'chargenet_colors.dart';
import 'chargenet_radii.dart';
import 'chargenet_spacing.dart';
import 'chargenet_text_styles.dart';

/// Builds [ThemeData] for ChargeNET mobile and desktop shells.
abstract final class ChargeNetTheme {
  /// Bottom sheets, full-bleed map — tighter radius and padding.
  static ThemeData mobile() => _build(isDesktop: false);

  /// Sidebar layout, data tables — wider radius and padding.
  static ThemeData desktop() => _build(isDesktop: true);

  static ThemeData _build({required bool isDesktop}) {
    final cardRadius = isDesktop ? ChargeNetRadii.lg : ChargeNetRadii.lg;
    final inputRadius = ChargeNetRadii.md;

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
      appBarTheme: AppBarTheme(
        backgroundColor: ChargeNetColors.background,
        foregroundColor: ChargeNetColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: ChargeNetTextStyles.title(),
      ),
      cardTheme: CardThemeData(
        color: ChargeNetColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ChargeNetColors.surfaceElevated,
        thickness: 1,
      ),
      textTheme: ChargeNetTextStyles.textTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ChargeNetColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ChargeNetSpacing.md,
          vertical: ChargeNetSpacing.sm + 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: ChargeNetColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: ChargeNetColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: ChargeNetColors.danger, width: 1.5),
        ),
        hintStyle: ChargeNetTextStyles.bodySm(color: ChargeNetColors.textMuted),
        labelStyle: ChargeNetTextStyles.label(color: ChargeNetColors.textSecondary),
        errorStyle: ChargeNetTextStyles.caption(color: ChargeNetColors.danger),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ChargeNetColors.surface,
        contentTextStyle: ChargeNetTextStyles.bodySm(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChargeNetRadii.md),
          side: const BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ChargeNetColors.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ChargeNetColors.primary,
        foregroundColor: ChargeNetColors.textPrimary,
      ),
    );
  }
}
