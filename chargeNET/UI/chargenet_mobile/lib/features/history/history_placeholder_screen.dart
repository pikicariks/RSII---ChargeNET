import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// History tab placeholder — M6.
class HistoryPlaceholderScreen extends StatelessWidget {
  const HistoryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history_rounded,
            size: 56,
            color: ChargeNetColors.textSecondary,
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          Text('History', style: ChargeNetTextStyles.title()),
          const SizedBox(height: ChargeNetSpacing.sm),
          Text(
            'Past sessions & reservations — M6',
            style: ChargeNetTextStyles.bodySm(),
          ),
        ],
      ),
    );
  }
}
