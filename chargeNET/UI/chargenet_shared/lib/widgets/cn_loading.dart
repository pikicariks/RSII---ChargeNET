import 'package:flutter/material.dart';

import '../theme/chargenet_colors.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';

/// Centered emerald progress indicator with optional message.
class CnLoading extends StatelessWidget {
  const CnLoading({
    super.key,
    this.message,
    this.expand = true,
  });

  final String? message;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: ChargeNetColors.primary),
        if (message != null) ...[
          const SizedBox(height: ChargeNetSpacing.md),
          Text(message!, style: ChargeNetTextStyles.bodySm()),
        ],
      ],
    );

    if (!expand) return content;
    return Center(child: content);
  }
}
