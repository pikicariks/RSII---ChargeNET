import '../api/json_utils.dart';

class ChargingSession {
  const ChargingSession({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.chargingStationId,
    required this.chargingStationName,
    required this.startTime,
    this.endTime,
    this.energyConsumedKwh,
    this.cost,
  });

  final int id;
  final int userId;
  final String userEmail;
  final int chargingStationId;
  final String chargingStationName;
  final DateTime startTime;
  final DateTime? endTime;
  final double? energyConsumedKwh;
  final double? cost;

  bool get isActive => endTime == null;

  factory ChargingSession.fromJson(Map<String, dynamic> json) {
    return ChargingSession(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userEmail: json['userEmail'] as String? ?? '',
      chargingStationId: (json['chargingStationId'] as num?)?.toInt() ?? 0,
      chargingStationName: json['chargingStationName'] as String? ?? '',
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
