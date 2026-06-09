import 'package:flutter/material.dart';

import '../theme/chargenet_colors.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';

/// ChargeNET logo block — emerald bolt + wordmark.
class CnBrandHeader extends StatelessWidget {
  const CnBrandHeader({
    super.key,
    this.subtitle,
    this.compact = false,
  });

  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 40.0 : 56.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bolt_rounded,
          size: iconSize,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: compact ? ChargeNetSpacing.sm : ChargeNetSpacing.md),
        Text(
          'ChargeNET',
          style: compact
              ? ChargeNetTextStyles.title()
              : ChargeNetTextStyles.heading(),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: ChargeNetSpacing.xs),
          Text(
            subtitle!,
            style: ChargeNetTextStyles.bodySm(color: ChargeNetColors.textMuted),
          ),
        ],
      ],
    );
  }
}
