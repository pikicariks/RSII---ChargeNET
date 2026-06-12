import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historySessionsProvider =
    AsyncNotifierProvider<HistorySessionsNotifier, List<ChargingSession>>(
  HistorySessionsNotifier.new,
);

final historyReservationsProvider =
    AsyncNotifierProvider<HistoryReservationsNotifier, List<Reservation>>(
  HistoryReservationsNotifier.new,
);

class HistorySessionsNotifier extends AsyncNotifier<List<ChargingSession>> {
  @override
  Future<List<ChargingSession>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    final items = await api.getSessions();
    items.sort((a, b) => b.startTime.compareTo(a.startTime));
    return items.where((s) => !s.isActive).toList();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      final items = await api.getSessions();
      items.sort((a, b) => b.startTime.compareTo(a.startTime));
      return items.where((s) => !s.isActive).toList();
    });
  }
}

class HistoryReservationsNotifier extends AsyncNotifier<List<Reservation>> {
  @override
  Future<List<Reservation>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    final items = await api.getReservations();
    items.sort((a, b) => b.reservationStart.compareTo(a.reservationStart));
    return items;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      final items = await api.getReservations();
      items.sort((a, b) => b.reservationStart.compareTo(a.reservationStart));
      return items;
    });
  }
}

Future<void> refreshHistory(WidgetRef ref) async {
  await Future.wait([
    ref.read(historySessionsProvider.notifier).reload(),
    ref.read(historyReservationsProvider.notifier).reload(),
  ]);
}
