/// REST path constants for ChargeNET WebAPI.
abstract final class ApiEndpoints {
  static const authLogin = '/api/auth/login';
  static const authRegister = '/api/auth/register';

  static const chargingStations = '/api/chargingstations';
  static String chargingStation(int id) => '/api/chargingstations/$id';

  static const connectors = '/api/connectors';
  static const tariffs = '/api/tariffs';
  static const chargingSessions = '/api/chargingsessions';
  static const faultReports = '/api/faultreports';
  static const transactions = '/api/transactions';

  static String recommendations({
    required double lat,
    required double lng,
    int topN = 5,
  }) =>
      '/api/recommendations?lat=$lat&lng=$lng&topN=$topN';
}
