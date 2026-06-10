import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Account settings — D-freestyle-settings (no Figma page).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;

    return CnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: ChargeNetTextStyles.title()),
          const SizedBox(height: ChargeNetSpacing.lg),
          _Row(label: 'Name', value: session?.fullName ?? '—'),
          _Row(label: 'Email', value: session?.email ?? '—'),
          _Row(label: 'Role', value: session?.role.apiName ?? '—'),
          const SizedBox(height: ChargeNetSpacing.lg),
          CnButton(
            label: 'Sign out',
            variant: CnButtonVariant.secondary,
            expand: false,
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChargeNetSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: ChargeNetTextStyles.bodySm()),
          ),
          Expanded(
            child: Text(value, style: ChargeNetTextStyles.body()),
          ),
        ],
      ),
    );
  }
}
