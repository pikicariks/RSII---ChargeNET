import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final activeTariffsProvider = FutureProvider<List<Tariff>>((ref) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getTariffs(isActive: true);
});

CnStationStatus statusBadgeFor(String statusName) {
  return switch (statusName.toLowerCase()) {
    'active' => CnStationStatus.active,
    'maintenance' => CnStationStatus.maintenance,
    _ => CnStationStatus.inactive,
  };
}
