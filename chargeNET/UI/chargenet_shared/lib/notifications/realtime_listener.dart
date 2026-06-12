import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/notification_providers.dart';

/// Watches auth + SignalR; shows snackbars for live notifications (M7 / D-freestyle-notif).
class RealtimeNotificationListener extends ConsumerWidget {
  const RealtimeNotificationListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(signalRConnectionProvider);

    ref.listen(realtimeNotificationProvider, (previous, next) {
      if (next == null || next == previous) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                next.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(next.message),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    });

    return child;
  }
}
