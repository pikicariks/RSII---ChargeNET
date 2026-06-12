import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import '../providers/app_providers.dart';
import 'signalr_service.dart';

final signalRServiceProvider = Provider<SignalRService>((ref) {
  final service = SignalRService();
  ref.onDispose(service.dispose);
  return service;
});

/// Latest push notification from SignalR (null until first event).
final realtimeNotificationProvider =
    StateProvider<AppNotification?>((ref) => null);

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsListNotifier, List<AppNotification>>(
  NotificationsListNotifier.new,
);

class NotificationsListNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    final items = await api.getNotifications();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      final items = await api.getNotifications();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Future<void> markRead(int id) async {
    final api = await ref.read(chargeNetApiProvider.future);
    await api.markNotificationRead(id);
    await reload();
  }
}

/// Connects SignalR when authenticated; exposes snackbar events via [realtimeNotificationProvider].
final signalRConnectionProvider = Provider<void>((ref) {
  final auth = ref.watch(authProvider);
  final service = ref.watch(signalRServiceProvider);

  if (auth.isAuthenticated && auth.session?.token != null) {
    unawaited(
      service.connect(accessToken: auth.session!.token).catchError((_) {}),
    );
  } else {
    unawaited(service.disconnect());
    ref.read(realtimeNotificationProvider.notifier).state = null;
  }

  final sub = service.events.listen((notification) {
    ref.read(realtimeNotificationProvider.notifier).state = notification;
    ref.invalidate(notificationsListProvider);
  });

  ref.onDispose(sub.cancel);
});
