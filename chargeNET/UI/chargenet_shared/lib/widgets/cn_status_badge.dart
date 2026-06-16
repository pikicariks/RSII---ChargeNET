import 'package:flutter/material.dart';

import '../theme/chargenet_colors.dart';
import '../theme/chargenet_radii.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';

/// Station / connector status pill matching Figma StatusBadge.tsx.
enum CnStationStatus {
  active,
  inactive,
  maintenance,
  charging,
}

class CnStatusBadge extends StatelessWidget {
  const CnStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final CnStationStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = _style;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? ChargeNetSpacing.sm : ChargeNetSpacing.md,
        vertical: compact ? 2 : ChargeNetSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ChargeNetRadii.md),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: ChargeNetTextStyles.caption(color: color).copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  (String, Color, Color) get _style => switch (status) {
        CnStationStatus.active => (
            'Active',
            ChargeNetColors.primary,
            ChargeNetColors.primaryMuted,
          ),
        CnStationStatus.inactive => (
            'Inactive',
            ChargeNetColors.textMuted,
            ChargeNetColors.surfaceElevated.withValues(alpha: 0.5),
          ),
        CnStationStatus.maintenance => (
            'Maintenance',
            ChargeNetColors.warning,
            ChargeNetColors.warning.withValues(alpha: 0.15),
          ),
        CnStationStatus.charging => (
            'Charging',
            ChargeNetColors.info,
            ChargeNetColors.info.withValues(alpha: 0.15),
          ),
      };
}
