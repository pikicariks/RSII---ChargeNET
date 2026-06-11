import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionFilter { all, active, completed }

class SessionsFilterState {
  const SessionsFilterState({
    this.status = SessionFilter.all,
    this.search = '',
  });

  final SessionFilter status;
  final String search;

  SessionsFilterState copyWith({SessionFilter? status, String? search}) {
    return SessionsFilterState(
      status: status ?? this.status,
      search: search ?? this.search,
    );
  }
}

final sessionsFilterProvider =
    NotifierProvider<SessionsFilterNotifier, SessionsFilterState>(
  SessionsFilterNotifier.new,
);

class SessionsFilterNotifier extends Notifier<SessionsFilterState> {
  @override
  SessionsFilterState build() => const SessionsFilterState();

  void setStatus(SessionFilter status) =>
      state = state.copyWith(status: status);

  void setSearch(String search) => state = state.copyWith(search: search);
}

final sessionsListProvider =
    AsyncNotifierProvider<SessionsListNotifier, List<ChargingSession>>(
  SessionsListNotifier.new,
);

class SessionsListNotifier extends AsyncNotifier<List<ChargingSession>> {
  @override
  Future<List<ChargingSession>> build() async {
    final filter = ref.watch(sessionsFilterProvider);
    final api = await ref.watch(chargeNetApiProvider.future);

    final isActive = switch (filter.status) {
      SessionFilter.active => true,
      SessionFilter.completed => false,
      SessionFilter.all => null,
    };

    var items = await api.getSessions(isActive: isActive);

    final q = filter.search.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items
          .where(
            (s) =>
                s.userEmail.toLowerCase().contains(q) ||
                s.chargingStationName.toLowerCase().contains(q),
          )
          .toList();
    }

    items.sort((a, b) => b.startTime.compareTo(a.startTime));
    return items;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => build());
  }
}

/// Pending reservations for admin confirm (statusId 1 = Pending).
final pendingReservationsProvider =
    FutureProvider<List<Reservation>>((ref) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getReservations(statusId: 1);
});

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  return '${local.day}.${local.month}.${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String formatSessionDateTime(DateTime dt) => _formatDateTime(dt);
