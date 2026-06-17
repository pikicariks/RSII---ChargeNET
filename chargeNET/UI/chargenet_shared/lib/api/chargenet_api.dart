import 'dart:typed_data';

import '../api/json_utils.dart';
import '../models/charging_session.dart';
import '../models/charging_station.dart';
import '../models/connector.dart';
import '../models/fault_report.dart';
import '../models/invoice.dart';
import '../models/notification.dart';
import '../models/paged_response.dart';
import '../models/recommended_station.dart';
import '../models/reference_data.dart';
import '../models/vehicle.dart';
import '../models/reservation.dart';
import '../models/tariff.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/wallet.dart';
import 'api_client.dart';
import 'endpoints.dart';

/// Typed read/write helpers on top of [ApiClient].
class ChargeNetApi {
  const ChargeNetApi(this._client);

  final ApiClient _client;

  Future<List<ChargingStation>> getStations({
    String? name,
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.chargingStations,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (name != null && name.isNotEmpty) 'name': name,
      },
      parser: ChargingStation.listFromJson,
    );
  }

  Future<PagedResponse<ChargingStation>> getStationsPaged({
    String? name,
    int page = 1,
    int pageSize = 20,
  }) {
    return _client.get(
      ApiEndpoints.chargingStations,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (name != null && name.isNotEmpty) 'name': name,
      },
      parser: (json) => PagedResponse.parse(json, ChargingStation.fromJson)
          .applyPage(page: page, pageSize: pageSize),
    );
  }

  Future<ChargingStation> getStation(int id) {
    return _client.get(
      ApiEndpoints.chargingStation(id),
      parser: (json) => ChargingStation.fromJson(parseJsonMap(json)),
    );
  }

  Future<ChargingStation> createStation(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.chargingStations,
      data: body,
      parser: (json) => ChargingStation.fromJson(parseJsonMap(json)),
    );
  }

  Future<ChargingStation> updateStation(int id, Map<String, dynamic> body) {
    return _client.put(
      ApiEndpoints.chargingStation(id),
      data: body,
      parser: (json) => ChargingStation.fromJson(parseJsonMap(json)),
    );
  }

  Future<void> deleteStation(int id) {
    return _client.delete(ApiEndpoints.chargingStation(id));
  }

  Future<List<Connector>> getConnectors({
    int? chargingStationId,
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.connectors,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (chargingStationId != null) 'chargingStationId': chargingStationId,
      },
      parser: Connector.listFromJson,
    );
  }

  Future<Connector> createConnector(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.connectors,
      data: body,
      parser: (json) => Connector.fromJson(parseJsonMap(json)),
    );
  }

  Future<void> deleteConnector(int id) {
    return _client.delete('${ApiEndpoints.connectors}/$id');
  }

  Future<List<RecommendedStation>> getRecommendations({
    required double lat,
    required double lng,
    int topN = 10,
  }) {
    return _client.get(
      ApiEndpoints.recommendations(lat: lat, lng: lng, topN: topN),
      parser: RecommendedStation.listFromJson,
    );
  }

  Future<List<ChargingSession>> getSessions({
    bool? isActive,
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.chargingSessions,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (isActive != null) 'isActive': isActive,
      },
      parser: ChargingSession.listFromJson,
    );
  }

  Future<PagedResponse<ChargingSession>> getSessionsPaged({
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) {
    return _client.get(
      ApiEndpoints.chargingSessions,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (isActive != null) 'isActive': isActive,
      },
      parser: (json) => PagedResponse.parse(json, ChargingSession.fromJson)
          .applyPage(page: page, pageSize: pageSize),
    );
  }

  Future<ChargingSession> getSession(int id) {
    return _client.get(
      ApiEndpoints.chargingSession(id),
      parser: (json) => ChargingSession.fromJson(parseJsonMap(json)),
    );
  }

  Future<ChargingSession> startSession({
    required int connectorId,
    required int tariffId,
    int? reservationId,
  }) {
    return _client.post(
      ApiEndpoints.chargingSessionsStart,
      data: {
        'connectorId': connectorId,
        'tariffId': tariffId,
        if (reservationId != null) 'reservationId': reservationId,
      },
      parser: (json) => ChargingSession.fromJson(parseJsonMap(json)),
    );
  }

  Future<ChargingSession> completeSession(int id, {required double energyKwh}) {
    return _client.post(
      ApiEndpoints.chargingSessionComplete(id),
      data: {'energyConsumedKWh': energyKwh},
      parser: (json) => ChargingSession.fromJson(parseJsonMap(json)),
    );
  }

  Future<List<Reservation>> getReservations({
    int? statusId,
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.reservations,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (statusId != null) 'statusId': statusId,
      },
      parser: Reservation.listFromJson,
    );
  }

  Future<Reservation> getReservation(int id) {
    return _client.get(
      ApiEndpoints.reservation(id),
      parser: (json) => Reservation.fromJson(parseJsonMap(json)),
    );
  }

  Future<Reservation> createReservation(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.reservations,
      data: body,
      parser: (json) => Reservation.fromJson(parseJsonMap(json)),
    );
  }

  Future<Reservation> cancelReservation(int id) {
    return _client.post(
      ApiEndpoints.reservationCancel(id),
      parser: (json) => Reservation.fromJson(parseJsonMap(json)),
    );
  }

  Future<Reservation> confirmReservation(int id) {
    return _client.post(
      ApiEndpoints.reservationConfirm(id),
      parser: (json) => Reservation.fromJson(parseJsonMap(json)),
    );
  }

  Future<List<ChargeNetUser>> getUsers({
    String? fullText,
    int? roleId,
    bool includeDeleted = false,
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.users,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (fullText != null && fullText.isNotEmpty) 'fullText': fullText,
        if (roleId != null) 'roleId': roleId,
        if (includeDeleted) 'includeDeleted': true,
      },
      parser: ChargeNetUser.listFromJson,
    );
  }

  Future<PagedResponse<ChargeNetUser>> getUsersPaged({
    String? fullText,
    int? roleId,
    bool includeDeleted = false,
    int page = 1,
    int pageSize = 20,
  }) {
    return _client.get(
      ApiEndpoints.users,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (fullText != null && fullText.isNotEmpty) 'fullText': fullText,
        if (roleId != null) 'roleId': roleId,
        if (includeDeleted) 'includeDeleted': true,
      },
      parser: (json) => PagedResponse.parse(json, ChargeNetUser.fromJson)
          .applyPage(page: page, pageSize: pageSize),
    );
  }

  Future<ChargeNetUser> getUser(int id) {
    return _client.get(
      ApiEndpoints.user(id),
      parser: (json) => ChargeNetUser.fromJson(parseJsonMap(json)),
    );
  }

  Future<ChargeNetUser> getMyProfile() {
    return _client.get(
      ApiEndpoints.profileMe,
      parser: (json) => ChargeNetUser.fromJson(parseJsonMap(json)),
    );
  }

  Future<ChargeNetUser> updateMyProfile(Map<String, dynamic> body) {
    return _client.put(
      ApiEndpoints.profileMe,
      data: body,
      parser: (json) => ChargeNetUser.fromJson(parseJsonMap(json)),
    );
  }

  Future<List<ReferenceItem>> getReferenceRoles({
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.referenceRoles,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: ReferenceItem.listFromJson,
    );
  }

  Future<List<CityReferenceItem>> getReferenceCities({
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.referenceCities,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: CityReferenceItem.listFromJson,
    );
  }

  Future<List<ReferenceItem>> getReferenceStationStatuses({
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.referenceStationStatuses,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: ReferenceItem.listFromJson,
    );
  }

  Future<List<ReferenceItem>> getReferenceConnectorTypes({
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.referenceConnectorTypes,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: ReferenceItem.listFromJson,
    );
  }

  Future<ChargeNetUser> createUser(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.users,
      data: body,
      parser: (json) => ChargeNetUser.fromJson(parseJsonMap(json)),
    );
  }

  Future<ChargeNetUser> updateUser(int id, Map<String, dynamic> body) {
    return _client.put(
      ApiEndpoints.user(id),
      data: body,
      parser: (json) => ChargeNetUser.fromJson(parseJsonMap(json)),
    );
  }

  Future<void> deleteUser(int id) {
    return _client.delete(ApiEndpoints.user(id));
  }

  Future<List<FaultReport>> getFaultReports({
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.faultReports,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: FaultReport.listFromJson,
    );
  }

  Future<PagedResponse<FaultReport>> getFaultReportsPaged({
    int page = 1,
    int pageSize = 20,
  }) {
    return _client.get(
      ApiEndpoints.faultReports,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: (json) => PagedResponse.parse(json, FaultReport.fromJson)
          .applyPage(page: page, pageSize: pageSize),
    );
  }

  Future<FaultReport> updateFaultReport(int id, Map<String, dynamic> body) {
    return _client.put(
      ApiEndpoints.faultReport(id),
      data: body,
      parser: (json) => FaultReport.fromJson(parseJsonMap(json)),
    );
  }

  Future<List<Vehicle>> getVehicles({
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.vehicles,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: Vehicle.listFromJson,
    );
  }

  Future<Vehicle> createVehicle(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.vehicles,
      data: body,
      parser: (json) => Vehicle.fromJson(parseJsonMap(json)),
    );
  }

  Future<Vehicle> updateVehicle(int id, Map<String, dynamic> body) {
    return _client.put(
      ApiEndpoints.vehicle(id),
      data: body,
      parser: (json) => Vehicle.fromJson(parseJsonMap(json)),
    );
  }

  Future<void> deleteVehicle(int id) {
    return _client.delete(ApiEndpoints.vehicle(id));
  }

  Future<List<AppNotification>> getNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (isRead != null) 'isRead': isRead,
      },
      parser: AppNotification.listFromJson,
    );
  }

  Future<AppNotification> markNotificationRead(int id) {
    return _client.patch(
      ApiEndpoints.notificationMarkRead(id),
      parser: (json) => AppNotification.fromJson(parseJsonMap(json)),
    );
  }

  Future<List<Invoice>> getInvoices({
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.invoices,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: Invoice.listFromJson,
    );
  }

  Future<List<Transaction>> getTransactions({
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.transactions,
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: Transaction.listFromJson,
    );
  }

  Future<List<Tariff>> getTariffs({
    bool? isActive,
    int page = 1,
    int pageSize = 100,
  }) {
    return _client.get(
      ApiEndpoints.tariffs,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (isActive != null) 'isActive': isActive,
      },
      parser: Tariff.listFromJson,
    );
  }

  Future<PagedResponse<Tariff>> getTariffsPaged({
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) {
    return _client.get(
      ApiEndpoints.tariffs,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (isActive != null) 'isActive': isActive,
      },
      parser: (json) => PagedResponse.parse(json, Tariff.fromJson)
          .applyPage(page: page, pageSize: pageSize),
    );
  }

  Future<Uint8List> downloadRevenueReportPdf({
    required DateTime from,
    required DateTime to,
  }) {
    return _client.getBytes(
      ApiEndpoints.reportsRevenuePdf,
      queryParameters: _reportDateQuery(from: from, to: to),
    );
  }

  Future<Uint8List> downloadSessionsReportPdf({
    required DateTime from,
    required DateTime to,
  }) {
    return _client.getBytes(
      ApiEndpoints.reportsSessionsPdf,
      queryParameters: _reportDateQuery(from: from, to: to),
    );
  }

  Map<String, String> _reportDateQuery({
    required DateTime from,
    required DateTime to,
  }) {
    String format(DateTime dt) {
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }

    return {
      'from': format(from),
      'to': format(to),
    };
  }

  Future<Tariff> getTariff(int id) {
    return _client.get(
      ApiEndpoints.tariff(id),
      parser: (json) => Tariff.fromJson(parseJsonMap(json)),
    );
  }

  Future<Tariff> createTariff(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.tariffs,
      data: body,
      parser: (json) => Tariff.fromJson(parseJsonMap(json)),
    );
  }

  Future<Tariff> updateTariff(int id, Map<String, dynamic> body) {
    return _client.put(
      ApiEndpoints.tariff(id),
      data: body,
      parser: (json) => Tariff.fromJson(parseJsonMap(json)),
    );
  }

  Future<void> deleteTariff(int id) {
    return _client.delete(ApiEndpoints.tariff(id));
  }

  Future<WalletBalance> getWalletBalance() {
    return _client.get(
      ApiEndpoints.walletBalance,
      parser: (json) => WalletBalance.fromJson(parseJsonMap(json)),
    );
  }

  Future<List<Transaction>> getWalletTransactions() {
    return _client.get(
      ApiEndpoints.walletTransactions,
      parser: Transaction.listFromJson,
    );
  }

  Future<WalletTopUpResult> topUpWallet({
    required double amount,
    String currency = 'EUR',
  }) {
    return _client.post(
      ApiEndpoints.walletTopUp,
      data: {'amount': amount, 'currency': currency},
      parser: (json) => WalletTopUpResult.fromJson(parseJsonMap(json)),
    );
  }

  Future<WalletTopUpResult> syncTopUpPayment(int transactionId) {
    return _client.post(
      ApiEndpoints.walletTopUpSync(transactionId),
      parser: (json) => WalletTopUpResult.fromJson(parseJsonMap(json)),
    );
  }
}
