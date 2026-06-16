import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chargenet_colors.dart';

/// Typography scale — Inter weights 400/500/600 matching Figma text-* classes.
///
/// | Style   | px | Weight | Figma      |
/// |---------|----|--------|------------|
/// | caption | 12 | 400    | text-xs    |
/// | bodySm  | 14 | 400    | text-sm    |
/// | body    | 16 | 400    | text-base  |
/// | bodyLg  | 18 | 400    | text-lg    |
/// | title   | 20 | 600    | text-xl    |
/// | heading | 24 | 600    | text-2xl   |
abstract final class ChargeNetTextStyles {
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle caption({Color color = ChargeNetColors.textMuted}) =>
      _base(size: 12, weight: FontWeight.w400, color: color).copyWith(height: 1.35);

  static TextStyle bodySm({Color color = ChargeNetColors.textSecondary}) =>
      _base(size: 14, weight: FontWeight.w400, color: color);

  static TextStyle body({Color color = ChargeNetColors.textPrimary}) =>
      _base(size: 16, weight: FontWeight.w400, color: color);

  static TextStyle bodyLg({Color color = ChargeNetColors.textPrimary}) =>
      _base(size: 18, weight: FontWeight.w400, color: color);

  static TextStyle label({Color color = ChargeNetColors.textPrimary}) =>
      _base(size: 14, weight: FontWeight.w500, color: color);

  static TextStyle title({Color color = ChargeNetColors.textPrimary}) =>
      _base(size: 20, weight: FontWeight.w600, color: color).copyWith(height: 1.25);

  static TextStyle heading({Color color = ChargeNetColors.textPrimary}) =>
      _base(size: 24, weight: FontWeight.w600, color: color).copyWith(height: 1.2);

  /// Builds a full [TextTheme] for [ThemeData].
  static TextTheme textTheme() {
    return TextTheme(
      headlineMedium: heading(),
      titleLarge: title(),
      titleMedium: bodyLg(),
      bodyLarge: body(),
      bodyMedium: bodySm(),
      bodySmall: caption(),
      labelLarge: label(),
    );
  }
}
