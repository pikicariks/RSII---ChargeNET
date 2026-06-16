import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopReferenceData {
  const DesktopReferenceData({
    required this.roles,
    required this.cities,
    required this.stationStatuses,
    required this.connectorTypes,
  });

  final List<ReferenceItem> roles;
  final List<CityReferenceItem> cities;
  final List<ReferenceItem> stationStatuses;
  final List<ReferenceItem> connectorTypes;
}

final desktopReferenceDataProvider =
    FutureProvider<DesktopReferenceData>((ref) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  final roles = await api.getReferenceRoles();
  final cities = await api.getReferenceCities();
  final stationStatuses = await api.getReferenceStationStatuses();
  final connectorTypes = await api.getReferenceConnectorTypes();

  return DesktopReferenceData(
    roles: roles,
    cities: cities,
    stationStatuses: stationStatuses,
    connectorTypes: connectorTypes,
  );
});
