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

List<ReferenceItem> _fallbackRoles() => ChargeNetLookups.roles
    .map((r) => ReferenceItem(id: r.id, name: r.name))
    .toList();

List<CityReferenceItem> _fallbackCities() => [
      const CityReferenceItem(
        id: 1,
        name: 'Sarajevo',
        postalCode: '71000',
        countryId: 1,
        countryName: 'Bosnia and Herzegovina',
      ),
    ];

List<ReferenceItem> _fallbackStationStatuses() =>
    ChargeNetLookups.stationStatuses
        .map((s) => ReferenceItem(id: s.id, name: s.name))
        .toList();

List<ReferenceItem> _fallbackConnectorTypes() =>
    ChargeNetLookups.connectorTypes
        .map((t) => ReferenceItem(id: t.id, name: t.name))
        .toList();

final desktopReferenceDataProvider =
    FutureProvider<DesktopReferenceData>((ref) async {
  final api = await ref.watch(chargeNetApiProvider.future);

  Future<List<T>> load<T>(
    Future<List<T>> Function() loader,
    List<T> Function() fallback,
  ) async {
    try {
      final items = await loader();
      return items.isNotEmpty ? items : fallback();
    } catch (_) {
      return fallback();
    }
  }

  final roles = await load(
    api.getReferenceRoles,
    _fallbackRoles,
  );
  final cities = await load(
    api.getReferenceCities,
    _fallbackCities,
  );
  final stationStatuses = await load(
    api.getReferenceStationStatuses,
    _fallbackStationStatuses,
  );
  final connectorTypes = await load(
    api.getReferenceConnectorTypes,
    _fallbackConnectorTypes,
  );

  return DesktopReferenceData(
    roles: roles,
    cities: cities,
    stationStatuses: stationStatuses,
    connectorTypes: connectorTypes,
  );
});

List<CityReferenceItem> stationFormCities(DesktopReferenceData? lookups) {
  final fromApi = (lookups?.cities ?? const <CityReferenceItem>[])
      .where((c) => c.name.toLowerCase() == 'sarajevo')
      .toList();
  if (fromApi.isNotEmpty) return fromApi;
  return _fallbackCities();
}

List<ReferenceItem> stationFormStatuses(DesktopReferenceData? lookups) {
  final fromApi = (lookups?.stationStatuses ?? const <ReferenceItem>[])
      .where((s) {
        final name = s.name.toLowerCase();
        return name == 'active' || name == 'inactive';
      })
      .toList();
  if (fromApi.isNotEmpty) return fromApi;

  return ChargeNetLookups.stationStatuses
      .where((s) => s.name == 'Active' || s.name == 'Inactive')
      .map((s) => ReferenceItem(id: s.id, name: s.name))
      .toList();
}

List<ReferenceItem> connectorFormTypes(DesktopReferenceData? lookups) {
  final fromApi = lookups?.connectorTypes ?? const <ReferenceItem>[];
  if (fromApi.isNotEmpty) return fromApi;
  return _fallbackConnectorTypes();
}
