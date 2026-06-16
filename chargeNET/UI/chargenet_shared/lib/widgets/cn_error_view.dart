import 'package:flutter/material.dart';

import '../theme/chargenet_colors.dart';
import '../theme/chargenet_radii.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';
import 'cn_button.dart';

/// Error state with message and optional retry action.
class CnErrorView extends StatelessWidget {
  const CnErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.expand = true,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(ChargeNetSpacing.lg),
      decoration: BoxDecoration(
        color: ChargeNetColors.surface,
        borderRadius: BorderRadius.circular(ChargeNetRadii.lg),
        border: Border.all(color: ChargeNetColors.surfaceElevated),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: ChargeNetColors.warning,
            size: 40,
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: ChargeNetTextStyles.body(),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: ChargeNetSpacing.lg),
            CnButton(
              label: 'Try again',
              onPressed: onRetry,
              variant: CnButtonVariant.secondary,
              expand: false,
            ),
          ],
        ],
      ),
    );

    if (!expand) return content;
    return Center(child: content);
  }
}
