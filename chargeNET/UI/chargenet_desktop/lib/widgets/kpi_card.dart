import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CnCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: ChargeNetColors.primary, size: 22),
                const Spacer(),
                Text(label, style: ChargeNetTextStyles.bodySm()),
              ],
            ),
            const SizedBox(height: ChargeNetSpacing.md),
            Text(value, style: ChargeNetTextStyles.heading()),
            if (subtitle != null) ...[
              const SizedBox(height: ChargeNetSpacing.xs),
              Text(subtitle!, style: ChargeNetTextStyles.caption()),
            ],
          ],
        ),
      ),
    );
  }
}
