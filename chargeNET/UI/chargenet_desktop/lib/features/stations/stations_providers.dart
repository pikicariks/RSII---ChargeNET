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

  @override
  Future<PagedResponse<ChargingStation>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    return api.getStationsPaged(
      name: _search.isEmpty ? null : _search,
      page: _page,
      pageSize: _pageSize,
    );
  }

  Future<void> search(String query) async {
    _search = query;
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
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      return api.getStationsPaged(
        name: _search.isEmpty ? null : _search,
        page: _page,
        pageSize: _pageSize,
      );
    });
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
