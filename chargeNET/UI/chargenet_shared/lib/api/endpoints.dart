/// REST path constants for ChargeNET WebAPI.
abstract final class ApiEndpoints {
  static const authLogin = '/api/auth/login';
  static const authRegister = '/api/auth/register';
  static const authPasswordResetRequest = '/api/auth/password-reset/request';
  static const authPasswordResetConfirm = '/api/auth/password-reset/confirm';

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
  static const profileMe = '/api/profile/me';
  static const referenceCountries = '/api/reference-data/countries';
  static const referenceCities = '/api/reference-data/cities';
  static const referenceRoles = '/api/reference-data/roles';
  static const referenceStationStatuses = '/api/reference-data/station-statuses';
  static const referenceReservationStatuses =
      '/api/reference-data/reservation-statuses';
  static const referenceConnectorTypes = '/api/reference-data/connector-types';

  static const walletBalance = '/api/wallet/balance';
  static const walletTransactions = '/api/wallet/transactions';
  static const walletTopUp = '/api/wallet/topup';
  static const faultReports = '/api/faultreports';
  static String faultReport(int id) => '/api/faultreports/$id';

  static const vehicles = '/api/vehicles';
  static String vehicle(int id) => '/api/vehicles/$id';

  static const notifications = '/api/notifications';
  static String notification(int id) => '/api/notifications/$id';
  static String notificationMarkRead(int id) =>
      '/api/notifications/$id/mark-read';

  static const invoices = '/api/invoices';
  static const transactions = '/api/transactions';
  static String reportsRevenuePdf({
    required DateTime from,
    required DateTime to,
  }) =>
      '/api/reports/revenue.pdf?from=${from.toIso8601String()}&to=${to.toIso8601String()}';
  static String reportsSessionsPdf({
    required DateTime from,
    required DateTime to,
  }) =>
      '/api/reports/sessions.pdf?from=${from.toIso8601String()}&to=${to.toIso8601String()}';

  static const notificationHub = '/hubs/notifications';

  static String recommendations({
    required double lat,
    required double lng,
    int topN = 5,
  }) =>
      '/api/recommendations?lat=$lat&lng=$lng&topN=$topN';
}
