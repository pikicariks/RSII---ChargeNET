import '../api/json_utils.dart';

class ChargingSession {
  const ChargingSession({
    required this.id,
    this.reservationId,
    required this.userId,
    required this.userEmail,
    required this.connectorId,
    required this.connectorLabel,
    required this.chargingStationId,
    required this.chargingStationName,
    required this.tariffId,
    required this.tariffName,
    required this.startTime,
    this.endTime,
    this.energyConsumedKwh,
    this.cost,
  });

  final int id;
  final int? reservationId;
  final int userId;
  final String userEmail;
  final int connectorId;
  final String connectorLabel;
  final int chargingStationId;
  final String chargingStationName;
  final int tariffId;
  final String tariffName;
  final DateTime startTime;
  final DateTime? endTime;
  final double? energyConsumedKwh;
  final double? cost;

  bool get isActive => endTime == null;

  factory ChargingSession.fromJson(Map<String, dynamic> json) {
    return ChargingSession(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reservationId: (json['reservationId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userEmail: json['userEmail'] as String? ?? '',
      connectorId: (json['connectorId'] as num?)?.toInt() ?? 0,
      connectorLabel: json['connectorLabel'] as String? ?? '',
      chargingStationId: (json['chargingStationId'] as num?)?.toInt() ?? 0,
      chargingStationName: json['chargingStationName'] as String? ?? '',
      tariffId: (json['tariffId'] as num?)?.toInt() ?? 0,
      tariffName: json['tariffName'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      energyConsumedKwh: (json['energyConsumedKWh'] as num?)?.toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
    );
  }

  static List<ChargingSession> listFromJson(dynamic json) =>
      parseJsonList(json, ChargingSession.fromJson);
}
