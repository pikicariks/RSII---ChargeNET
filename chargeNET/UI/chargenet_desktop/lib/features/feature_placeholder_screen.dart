import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Generic feature placeholder until step implementation.
class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.step,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final String step;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ChargeNetColors.primary),
              const SizedBox(width: ChargeNetSpacing.sm),
              Text(title, style: ChargeNetTextStyles.title()),
            ],
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          Text(
            'Coming in $step',
            style: ChargeNetTextStyles.bodySm(),
          ),
        ],
      ),
    );
  }
}
