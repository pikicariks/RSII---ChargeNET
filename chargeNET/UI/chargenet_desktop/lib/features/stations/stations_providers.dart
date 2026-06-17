import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stationsListProvider =
    AsyncNotifierProvider<StationsListNotifier, PagedResponse<ChargingStation>>(
  StationsListNotifier.new,
);

class StationsListNotifier extends AsyncNotifier<PagedResponse<ChargingStation>> {
  String _search = '';
  int _page = 1;
  int _pageSize = 20;

  int get currentPage => _page;
  int get currentPageSize => _pageSize;
  String get currentSearch => _search;

  Future<PagedResponse<ChargingStation>> _load() async {
    final api = await ref.read(chargeNetApiProvider.future);
    final all = await api.getStations(pageSize: 100);

    var filtered = all;
    final query = _search.trim();
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = all.where((s) => s.name.toLowerCase().contains(q)).toList();
    }

    return PagedResponse<ChargingStation>(
      items: filtered,
      totalCount: filtered.length,
    ).applyPage(page: _page, pageSize: _pageSize);
  }

  @override
  Future<PagedResponse<ChargingStation>> build() async {
    ref.watch(chargeNetApiProvider.future);
    return _load();
  }

  Future<void> search(String query) async {
    _search = query.trim();
    _page = 1;
    await reload();
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

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final stationDetailProvider =
    FutureProvider.family<ChargingStation, int>((ref, id) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getStation(id);
});

final stationConnectorsProvider =
    FutureProvider.family<List<Connector>, int>((ref, stationId) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getConnectors(chargingStationId: stationId);
});

CnStationStatus statusBadgeFor(String statusName) {
  return switch (statusName.toLowerCase()) {
    'active' => CnStationStatus.active,
    'maintenance' => CnStationStatus.maintenance,
    _ => CnStationStatus.inactive,
  };
}
