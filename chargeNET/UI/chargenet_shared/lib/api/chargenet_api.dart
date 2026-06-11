import '../api/json_utils.dart';
import '../models/charging_session.dart';
import '../models/charging_station.dart';
import '../models/connector.dart';
import '../models/fault_report.dart';
import '../models/recommended_station.dart';
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

  Future<List<ChargingStation>> getStations({String? name}) {
    return _client.get(
      ApiEndpoints.chargingStations,
      queryParameters: name != null && name.isNotEmpty ? {'name': name} : null,
      parser: ChargingStation.listFromJson,
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

  Future<List<Connector>> getConnectors({int? chargingStationId}) {
    return _client.get(
      ApiEndpoints.connectors,
      queryParameters: chargingStationId != null
          ? {'chargingStationId': chargingStationId}
          : null,
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

  Future<List<ChargingSession>> getSessions({bool? isActive}) {
    return _client.get(
      ApiEndpoints.chargingSessions,
      queryParameters: isActive != null ? {'isActive': isActive} : null,
      parser: ChargingSession.listFromJson,
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

  Future<List<Reservation>> getReservations({int? statusId}) {
    return _client.get(
      ApiEndpoints.reservations,
      queryParameters: statusId != null ? {'statusId': statusId} : null,
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
  }) {
    return _client.get(
      ApiEndpoints.users,
      queryParameters: {
        if (fullText != null && fullText.isNotEmpty) 'fullText': fullText,
        if (roleId != null) 'roleId': roleId,
        if (includeDeleted) 'includeDeleted': true,
      },
      parser: ChargeNetUser.listFromJson,
    );
  }

  Future<ChargeNetUser> getUser(int id) {
    return _client.get(
      ApiEndpoints.user(id),
      parser: (json) => ChargeNetUser.fromJson(parseJsonMap(json)),
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

  Future<List<FaultReport>> getFaultReports() {
    return _client.get(
      ApiEndpoints.faultReports,
      parser: FaultReport.listFromJson,
    );
  }

  Future<List<Transaction>> getTransactions() {
    return _client.get(
      ApiEndpoints.transactions,
      parser: Transaction.listFromJson,
    );
  }

  Future<List<Tariff>> getTariffs({bool? isActive}) {
    return _client.get(
      ApiEndpoints.tariffs,
      queryParameters: isActive != null ? {'isActive': isActive} : null,
      parser: Tariff.listFromJson,
    );
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
}
