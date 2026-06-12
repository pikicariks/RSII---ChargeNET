import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Header bell dropdown — D-freestyle-notif.
class NotificationsPanel extends ConsumerWidget {
  const NotificationsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsListProvider);
    final unread = notifications.maybeWhen(
      data: (items) => items.where((n) => !n.isRead).length,
      orElse: () => 0,
    );

    return PopupMenuButton<void>(
      tooltip: 'Notifications',
      offset: const Offset(0, 48),
      color: ChargeNetColors.surface,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (unread > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ChargeNetColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      itemBuilder: (context) {
        return notifications.when(
          loading: () => [
            const PopupMenuItem(
              enabled: false,
              child: Text('Loading…'),
            ),
          ],
          error: (e, _) => [
            PopupMenuItem(
              enabled: false,
              child: Text('Error: $e'),
            ),
          ],
          data: (items) {
            if (items.isEmpty) {
              return [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('No notifications'),
                ),
              ];
            }
            return [
              for (final n in items.take(8))
                PopupMenuItem(
                  onTap: () {
                    if (!n.isRead) {
                      ref
                          .read(notificationsListProvider.notifier)
                          .markRead(n.id);
                    }
                  },
                  child: SizedBox(
                    width: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: ChargeNetTextStyles.label(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          n.message,
                          style: ChargeNetTextStyles.caption(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ];
          },
        );
      },
    );
  }
}
