import '../api/json_utils.dart';

class Connector {
  const Connector({
    required this.id,
    required this.chargingStationId,
    required this.chargingStationName,
    required this.connectorTypeId,
    required this.connectorTypeName,
    required this.isAvailable,
    required this.powerKw,
    this.label,
  });

  final int id;
  final int chargingStationId;
  final String chargingStationName;
  final int connectorTypeId;
  final String connectorTypeName;
  final bool isAvailable;
  final double powerKw;
  final String? label;

  factory Connector.fromJson(Map<String, dynamic> json) {
    return Connector(
      id: (json['id'] as num?)?.toInt() ?? 0,
      chargingStationId: (json['chargingStationId'] as num?)?.toInt() ?? 0,
      chargingStationName: json['chargingStationName'] as String? ?? '',
      connectorTypeId: (json['connectorTypeId'] as num?)?.toInt() ?? 0,
      connectorTypeName: json['connectorTypeName'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      powerKw: (json['powerKW'] as num?)?.toDouble() ?? 0,
      label: json['label'] as String?,
    );
  }

  static List<Connector> listFromJson(dynamic json) =>
      parseJsonList(json, Connector.fromJson);
}
