import '../api/json_utils.dart';
import '../models/charging_session.dart';
import '../models/charging_station.dart';
import '../models/connector.dart';
import '../models/fault_report.dart';
import '../models/recommended_station.dart';
import '../models/tariff.dart';
import '../models/transaction.dart';
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

  Future<List<ChargingSession>> getSessions() {
    return _client.get(
      ApiEndpoints.chargingSessions,
      parser: ChargingSession.listFromJson,
    );
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
}
