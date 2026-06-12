import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// M-freestyle-help — static FAQ placeholder.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      'How do I reserve a charger?',
      'Open a station on the map, tap Reserve, pick a time slot and confirm.',
    ),
    (
      'How does wallet top-up work?',
      'Profile → Wallet → choose an amount. Complete payment in Stripe test mode.',
    ),
    (
      'Need help with a station fault?',
      'Contact support at support@chargenet.com or report via the admin dashboard.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
        children: [
          Text(
            'Frequently asked questions',
            style: ChargeNetTextStyles.title(),
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          for (final (q, a) in _faqs)
            Padding(
              padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
              child: CnCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q, style: ChargeNetTextStyles.label()),
                    const SizedBox(height: ChargeNetSpacing.xs),
                    Text(a, style: ChargeNetTextStyles.bodySm()),
                  ],
                ),
              ),
            ),
          const SizedBox(height: ChargeNetSpacing.lg),
          CnCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact', style: ChargeNetTextStyles.label()),
                const SizedBox(height: ChargeNetSpacing.xs),
                Text(
                  'support@chargenet.com · +387 33 000 000',
                  style: ChargeNetTextStyles.bodySm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
