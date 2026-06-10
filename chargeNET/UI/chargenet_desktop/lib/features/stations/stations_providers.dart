import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stationsListProvider =
    AsyncNotifierProvider<StationsListNotifier, List<ChargingStation>>(
  StationsListNotifier.new,
);

class StationsListNotifier extends AsyncNotifier<List<ChargingStation>> {
  String _search = '';

  @override
  Future<List<ChargingStation>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    return api.getStations(name: _search.isEmpty ? null : _search);
  }

  Future<void> search(String query) async {
    _search = query;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      return api.getStations(name: _search.isEmpty ? null : _search);
    });
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      return api.getStations(name: _search.isEmpty ? null : _search);
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
