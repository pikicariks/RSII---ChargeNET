/// Seeded lookup values from ChargeNetSeed.cs (no Cities API yet).
abstract final class ChargeNetLookups {  static const cities = [
    (id: 1, name: 'Sarajevo'),
    (id: 2, name: 'Banja Luka'),
    (id: 3, name: 'Tuzla'),
    (id: 4, name: 'Mostar'),
    (id: 5, name: 'Zenica'),
    (id: 6, name: 'Zagreb'),
    (id: 7, name: 'Split'),
  ];

  static const stationStatuses = [
    (id: 1, name: 'Active'),
    (id: 2, name: 'Inactive'),
    (id: 3, name: 'Maintenance'),
  ];

  static const connectorTypes = [
    (id: 1, name: 'Type 2'),
    (id: 2, name: 'CCS'),
    (id: 3, name: 'CHAdeMO'),
  ];

  static const roles = [
    (id: 1, name: 'Admin'),
    (id: 2, name: 'Technician'),
    (id: 3, name: 'Driver'),
  ];

  static String cityName(int cityId) =>
      cities.firstWhere((c) => c.id == cityId, orElse: () => cities.first).name;
}
