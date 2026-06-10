import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile tab placeholder — M6 settings & account.
class ProfilePlaceholderScreen extends ConsumerWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ChargeNetSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: ChargeNetColors.primaryMuted,
              child: Text(
                session?.firstName.isNotEmpty == true
                    ? session!.firstName[0].toUpperCase()
                    : '?',
                style: ChargeNetTextStyles.title(color: ChargeNetColors.primary),
              ),
            ),
            const SizedBox(height: ChargeNetSpacing.md),
            Text(
              session?.fullName ?? 'Profile',
              style: ChargeNetTextStyles.title(),
            ),
            const SizedBox(height: ChargeNetSpacing.xs),
            Text(
              session?.email ?? '',
              style: ChargeNetTextStyles.bodySm(),
            ),
            const SizedBox(height: ChargeNetSpacing.lg),
            CnButton(
              label: 'Sign out',
              variant: CnButtonVariant.secondary,
              expand: false,
              onPressed: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}
