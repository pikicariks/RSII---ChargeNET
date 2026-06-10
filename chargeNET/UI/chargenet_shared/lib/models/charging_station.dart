import '../api/json_utils.dart';

class ChargingStation {
  const ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.cityId,
    required this.cityName,
    required this.statusId,
    required this.statusName,
    this.latitude,
    this.longitude,
    this.rating,
    this.connectorCount = 0,
    this.maxPowerKw,
    this.isFastCharger = false,
  });

  final int id;
  final String name;
  final String address;
  final int cityId;
  final String cityName;
  final int statusId;
  final String statusName;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int connectorCount;
  final double? maxPowerKw;
  final bool isFastCharger;

  bool get isActive => statusName.toLowerCase() == 'active';

  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    return ChargingStation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      cityId: (json['cityId'] as num?)?.toInt() ?? 0,
      cityName: json['cityName'] as String? ?? '',
      statusId: (json['statusId'] as num?)?.toInt() ?? 0,
      statusName: json['statusName'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      connectorCount: (json['connectorCount'] as num?)?.toInt() ?? 0,
      maxPowerKw: (json['maxPowerKW'] as num?)?.toDouble(),
      isFastCharger: json['isFastCharger'] as bool? ?? false,
    );
  }

  static List<ChargingStation> listFromJson(dynamic json) =>
      parseJsonList(json, ChargingStation.fromJson);

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'address': address,
        'cityId': cityId,
        'latitude': latitude,
        'longitude': longitude,
        'statusId': statusId,
        'isFastCharger': isFastCharger,
        if (maxPowerKw != null) 'maxPowerKW': maxPowerKw,
        if (rating != null) 'rating': rating,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'address': address,
        'cityId': cityId,
        'latitude': latitude,
        'longitude': longitude,
        'statusId': statusId,
        'isFastCharger': isFastCharger,
        if (maxPowerKw != null) 'maxPowerKW': maxPowerKw,
        if (rating != null) 'rating': rating,
      };
}
