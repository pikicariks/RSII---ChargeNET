import '../api/json_utils.dart';

class RecommendedStation {
  const RecommendedStation({
    required this.id,
    required this.name,
    required this.address,
    required this.cityName,
    required this.statusName,
    this.latitude,
    this.longitude,
    this.connectorCount = 0,
    this.estimatedPricePerKwh = 0,
    this.distanceKm = 0,
    this.score = 0,
    this.baseScore = 0,
    this.occupancyPenalty = 0,
    this.rating,
  });

  final int id;
  final String name;
  final String address;
  final String cityName;
  final String statusName;
  final double? latitude;
  final double? longitude;
  final int connectorCount;
  final double estimatedPricePerKwh;
  final double distanceKm;
  final double score;
  final double baseScore;
  final double occupancyPenalty;
  final double? rating;

  bool get isActive => statusName.toLowerCase() == 'active';

  factory RecommendedStation.fromJson(Map<String, dynamic> json) {
    return RecommendedStation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      statusName: json['statusName'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      connectorCount: (json['connectorCount'] as num?)?.toInt() ?? 0,
      estimatedPricePerKwh:
          (json['estimatedPricePerKWh'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      baseScore: (json['baseScore'] as num?)?.toDouble() ?? 0,
      occupancyPenalty: (json['occupancyPenalty'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  static List<RecommendedStation> listFromJson(dynamic json) =>
      parseJsonList(json, RecommendedStation.fromJson);
}
