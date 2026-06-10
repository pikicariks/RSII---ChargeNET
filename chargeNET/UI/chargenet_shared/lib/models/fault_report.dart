import '../api/json_utils.dart';

class FaultReport {
  const FaultReport({
    required this.id,
    required this.chargingStationName,
    required this.description,
    required this.isResolved,
    required this.reportedAt,
  });

  final int id;
  final String chargingStationName;
  final String description;
  final bool isResolved;
  final DateTime reportedAt;

  factory FaultReport.fromJson(Map<String, dynamic> json) {
    return FaultReport(
      id: (json['id'] as num?)?.toInt() ?? 0,
      chargingStationName: json['chargingStationName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isResolved: json['isResolved'] as bool? ?? false,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
    );
  }

  static List<FaultReport> listFromJson(dynamic json) =>
      parseJsonList(json, FaultReport.fromJson);
}
