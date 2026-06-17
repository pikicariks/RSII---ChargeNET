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

  void setStatus(SessionFilter status) {
    state = state.copyWith(status: status);
  }

  void setSearch(String search) {
    state = state.copyWith(search: search.trim());
  }
}

final sessionsListProvider =
    AsyncNotifierProvider<SessionsListNotifier, PagedResponse<ChargingSession>>(
  SessionsListNotifier.new,
);

class SessionsListNotifier extends AsyncNotifier<PagedResponse<ChargingSession>> {
  int _page = 1;
  int _pageSize = 20;
  SessionFilter? _lastStatus;
  String _lastSearch = '';

  int get currentPage => _page;
  int get currentPageSize => _pageSize;

  @override
  Future<PagedResponse<ChargingSession>> build() async {
    final filter = ref.watch(sessionsFilterProvider);
    if (filter.status != _lastStatus || filter.search != _lastSearch) {
      _page = 1;
      _lastStatus = filter.status;
      _lastSearch = filter.search;
    }

    final api = await ref.watch(chargeNetApiProvider.future);

    final isActive = switch (filter.status) {
      SessionFilter.active => true,
      SessionFilter.completed => false,
      SessionFilter.all => null,
    };

    final paged = await api.getSessionsPaged(
      isActive: isActive,
      page: 1,
      pageSize: 100,
    );
    var items = paged.items;

    final query = filter.search.trim();
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      items = items
          .where(
            (s) =>
                s.userEmail.toLowerCase().contains(q) ||
                s.chargingStationName.toLowerCase().contains(q),
          )
          .toList();
    }

    items.sort((a, b) => b.startTime.compareTo(a.startTime));

    return PagedResponse<ChargingSession>(
      items: items,
      totalCount: items.length,
    ).applyPage(page: _page, pageSize: _pageSize);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => build());
  }

  Future<void> nextPage() async {
    _page += 1;
    await reload();
  }

  Future<void> previousPage() async {
    if (_page > 1) {
      _page -= 1;
      await reload();
    }
  }

  Future<void> setPageSize(int pageSize) async {
    _pageSize = pageSize;
    _page = 1;
    await reload();
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
