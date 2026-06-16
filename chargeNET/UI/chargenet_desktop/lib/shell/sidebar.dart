import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:chargenet_desktop/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Fixed ~240px sidebar with emerald active nav (Figma Sidebar.tsx).
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key, required this.currentPath});

  final String currentPath;

  static const _width = 248.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      decoration: const BoxDecoration(
        color: ChargeNetColors.surface,
        border: Border(
          right: BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(ChargeNetSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: ChargeNetSpacing.sm),
                Expanded(
                  child: Text(
                    'ChargeNet Admin',
                    style: ChargeNetTextStyles.body(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: ChargeNetSpacing.sm,
                vertical: ChargeNetSpacing.md,
              ),
              children: [
                for (final item in adminNavItems)
                  _NavTile(
                    item: item,
                    selected: currentPath == item.path ||
                        (item.path == AdminRoutes.stations &&
                            currentPath.startsWith('${AdminRoutes.stations}/')),
                    onTap: () => context.go(item.path),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _Footer(onSettings: () => context.go(AdminRoutes.settings)),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AdminNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? ChargeNetColors.primaryMuted : Colors.transparent;
    final fg =
        selected ? ChargeNetColors.primary : ChargeNetColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: ChargeNetSpacing.xs),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(ChargeNetRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ChargeNetRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ChargeNetSpacing.md,
              vertical: ChargeNetSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: fg),
                const SizedBox(width: ChargeNetSpacing.sm),
                Expanded(
                  child: Text(
                    item.label,
                    style: ChargeNetTextStyles.bodySm(color: fg).copyWith(
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    final initials = session?.firstName.isNotEmpty == true
        ? session!.firstName[0].toUpperCase()
        : 'A';

    return Padding(
      padding: const EdgeInsets.all(ChargeNetSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: ChargeNetColors.primaryMuted,
            child: Text(
              initials,
              style: ChargeNetTextStyles.label(color: ChargeNetColors.primary),
            ),
          ),
          const SizedBox(width: ChargeNetSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session?.fullName ?? 'Admin',
                  style: ChargeNetTextStyles.caption(
                    color: ChargeNetColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  session?.role.apiName ?? '',
                  style: ChargeNetTextStyles.caption(),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined, size: 20),
            color: ChargeNetColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
