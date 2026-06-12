import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// M7 — in-app notification list.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(notificationsListProvider.notifier).reload(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const CnLoading(message: 'Loading notifications…'),
        error: (e, _) => CnErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(notificationsListProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: ChargeNetTextStyles.bodySm(),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final n = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
                child: CnCard(
                  gradientBorder: !n.isRead,
                  onTap: n.isRead
                      ? null
                      : () => ref
                          .read(notificationsListProvider.notifier)
                          .markRead(n.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: ChargeNetTextStyles.label(),
                            ),
                          ),
                          if (!n.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: ChargeNetColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: ChargeNetSpacing.xs),
                      Text(n.message, style: ChargeNetTextStyles.bodySm()),
                      const SizedBox(height: ChargeNetSpacing.xs),
                      Text(
                        formatChargeNetDateTime(n.createdAt),
                        style: ChargeNetTextStyles.caption(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
