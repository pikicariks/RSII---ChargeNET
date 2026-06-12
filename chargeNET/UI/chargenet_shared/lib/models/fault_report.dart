import '../api/json_utils.dart';

class FaultReport {
  const FaultReport({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.chargingStationId,
    required this.chargingStationName,
    this.connectorId,
    this.connectorLabel,
    required this.description,
    required this.isResolved,
    required this.reportedAt,
    this.resolvedAt,
  });

  final int id;
  final int userId;
  final String userEmail;
  final int chargingStationId;
  final String chargingStationName;
  final int? connectorId;
  final String? connectorLabel;
  final String description;
  final bool isResolved;
  final DateTime reportedAt;
  final DateTime? resolvedAt;

  factory FaultReport.fromJson(Map<String, dynamic> json) {
    return FaultReport(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userEmail: json['userEmail'] as String? ?? '',
      chargingStationId: (json['chargingStationId'] as num?)?.toInt() ?? 0,
      chargingStationName: json['chargingStationName'] as String? ?? '',
      connectorId: (json['connectorId'] as num?)?.toInt(),
      connectorLabel: json['connectorLabel'] as String?,
      description: json['description'] as String? ?? '',
      isResolved: json['isResolved'] as bool? ?? false,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  static List<FaultReport> listFromJson(dynamic json) =>
      parseJsonList(json, FaultReport.fromJson);
}
