import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// M-freestyle-settings — read-only account info + logout.
class MobileSettingsScreen extends ConsumerWidget {
  const MobileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
        children: [
          CnCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Name', value: session?.fullName ?? '—'),
                _InfoRow(label: 'Email', value: session?.email ?? '—'),
                _InfoRow(label: 'Role', value: session?.role.apiName ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          CnButton(
            label: 'Sign out',
            variant: CnButtonVariant.secondary,
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChargeNetSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: ChargeNetTextStyles.bodySm()),
          ),
          Expanded(child: Text(value, style: ChargeNetTextStyles.body())),
        ],
      ),
    );
  }
}
