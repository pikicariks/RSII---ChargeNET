import 'package:flutter/material.dart';

import '../theme/chargenet_colors.dart';
import '../theme/chargenet_radii.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';

enum CnButtonVariant { primary, secondary, destructive }

enum CnButtonSize { sm, md, lg }

/// ChargeNET button — primary emerald fill, secondary slate outline, destructive orange.
class CnButton extends StatelessWidget {
  const CnButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CnButtonVariant.primary,
    this.size = CnButtonSize.md,
    this.isLoading = false,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final CnButtonVariant variant;
  final CnButtonSize size;
  final bool isLoading;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final vertical = switch (size) {
      CnButtonSize.sm => ChargeNetSpacing.sm,
      CnButtonSize.md => ChargeNetSpacing.sm + 4,
      CnButtonSize.lg => ChargeNetSpacing.md,
    };
    final horizontal = switch (size) {
      CnButtonSize.sm => ChargeNetSpacing.md,
      CnButtonSize.md => ChargeNetSpacing.lg,
      CnButtonSize.lg => ChargeNetSpacing.xl,
    };

    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: ChargeNetSpacing.sm),
              ],
              Text(label, style: ChargeNetTextStyles.label(color: _textColor)),
            ],
          );

    final button = Material(
      color: _backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChargeNetRadii.md),
        side: BorderSide(color: _borderColor),
      ),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(ChargeNetRadii.md),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          child: child,
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Color get _backgroundColor => switch (variant) {
        CnButtonVariant.primary => ChargeNetColors.primary,
        CnButtonVariant.secondary => Colors.transparent,
        CnButtonVariant.destructive => ChargeNetColors.warning,
      };

  Color get _borderColor => switch (variant) {
        CnButtonVariant.primary => ChargeNetColors.primary,
        CnButtonVariant.secondary => ChargeNetColors.surfaceElevated,
        CnButtonVariant.destructive => ChargeNetColors.warning,
      };

  Color get _textColor => switch (variant) {
        CnButtonVariant.primary => ChargeNetColors.textPrimary,
        CnButtonVariant.secondary => ChargeNetColors.textPrimary,
        CnButtonVariant.destructive => ChargeNetColors.textPrimary,
      };
}
