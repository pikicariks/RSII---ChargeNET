import '../api/json_utils.dart';

class Vehicle {
  const Vehicle({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.make,
    required this.model,
    this.year,
    this.licensePlate,
    this.batteryCapacity,
    this.connectorTypeId,
    this.connectorTypeName,
  });

  final int id;
  final int userId;
  final String userEmail;
  final String make;
  final String model;
  final int? year;
  final String? licensePlate;
  final double? batteryCapacity;
  final int? connectorTypeId;
  final String? connectorTypeName;

  String get displayName => '$make $model${year != null ? ' ($year)' : ''}';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userEmail: json['userEmail'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt(),
      licensePlate: json['licensePlate'] as String?,
      batteryCapacity: (json['batteryCapacity'] as num?)?.toDouble(),
      connectorTypeId: (json['connectorTypeId'] as num?)?.toInt(),
      connectorTypeName: json['connectorTypeName'] as String?,
    );
  }

  static List<Vehicle> listFromJson(dynamic json) =>
      parseJsonList(json, Vehicle.fromJson);
}
