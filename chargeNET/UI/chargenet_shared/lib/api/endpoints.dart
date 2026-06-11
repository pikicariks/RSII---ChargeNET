/// REST path constants for ChargeNET WebAPI.
abstract final class ApiEndpoints {
  static const authLogin = '/api/auth/login';
  static const authRegister = '/api/auth/register';

  static const chargingStations = '/api/chargingstations';
  static String chargingStation(int id) => '/api/chargingstations/$id';

  static const connectors = '/api/connectors';
  static const tariffs = '/api/tariffs';
  static String tariff(int id) => '/api/tariffs/$id';
  static const chargingSessions = '/api/chargingsessions';
  static String chargingSession(int id) => '/api/chargingsessions/$id';
  static const chargingSessionsStart = '/api/chargingsessions/start';
  static String chargingSessionComplete(int id) =>
      '/api/chargingsessions/$id/complete';

  static const reservations = '/api/reservations';
  static String reservation(int id) => '/api/reservations/$id';
  static String reservationCancel(int id) => '/api/reservations/$id/cancel';
  static String reservationConfirm(int id) => '/api/reservations/$id/confirm';

  static const users = '/api/users';
  static String user(int id) => '/api/users/$id';

  static const walletBalance = '/api/wallet/balance';
  static const walletTransactions = '/api/wallet/transactions';
  static const walletTopUp = '/api/wallet/topup';
  static const faultReports = '/api/faultreports';
  static const transactions = '/api/transactions';

  static String recommendations({
    required double lat,
    required double lng,
    int topN = 5,
  }) =>
      '/api/recommendations?lat=$lat&lng=$lng&topN=$topN';
}
