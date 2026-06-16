import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// M6 — account menu, wallet link, vehicles, settings, help.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    final unread = ref.watch(notificationsListProvider).maybeWhen(
          data: (items) => items.where((n) => !n.isRead).length,
          orElse: () => 0,
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
          children: [
            const SizedBox(height: ChargeNetSpacing.lg),
            Center(
              child: CnCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: ChargeNetColors.primaryMuted,
                      child: Text(
                        session?.firstName.isNotEmpty == true
                            ? session!.firstName[0].toUpperCase()
                            : '?',
                        style: ChargeNetTextStyles.title(
                          color: ChargeNetColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: ChargeNetSpacing.md),
                    Text(
                      session?.fullName ?? 'Profile',
                      style: ChargeNetTextStyles.title(),
                    ),
                    Text(
                      session?.email ?? '',
                      style: ChargeNetTextStyles.bodySm(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ChargeNetSpacing.xl),
            _MenuTile(
              icon: Icons.edit_outlined,
              label: 'Edit profile',
              onTap: () => context.push('/profile/edit'),
            ),
            _MenuTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              onTap: () => context.push('/wallet'),
            ),
            _MenuTile(
              icon: Icons.directions_car_outlined,
              label: 'My vehicles',
              onTap: () => context.push('/vehicles'),
            ),
            _MenuTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              trailing: unread > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ChargeNetColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unread',
                        style: ChargeNetTextStyles.caption(
                          color: ChargeNetColors.textPrimary,
                        ),
                      ),
                    )
                  : null,
              onTap: () => context.push('/notifications'),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.push('/settings'),
            ),
            _MenuTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () => context.push('/help'),
            ),
            const SizedBox(height: ChargeNetSpacing.lg),
            CnButton(
              label: 'Sign out',
              variant: CnButtonVariant.secondary,
              onPressed: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
      child: CnCard(
        onTap: onTap,
        gradientBorder: true,
        child: Row(
          children: [
            Icon(icon, color: ChargeNetColors.primary),
            const SizedBox(width: ChargeNetSpacing.md),
            Expanded(
              child: Text(label, style: ChargeNetTextStyles.label()),
            ),
            if (trailing != null) trailing!,
            Icon(
              Icons.chevron_right_rounded,
              color: ChargeNetColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
