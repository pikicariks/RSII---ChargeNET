import '../api/json_utils.dart';

class ReferenceItem {
  const ReferenceItem({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    return ReferenceItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  static List<ReferenceItem> listFromJson(dynamic json) =>
      parseJsonList(json, ReferenceItem.fromJson);
}

class CityReferenceItem {
  const CityReferenceItem({
    required this.id,
    required this.name,
    required this.postalCode,
    required this.countryId,
    required this.countryName,
  });

  final int id;
  final String name;
  final String postalCode;
  final int countryId;
  final String countryName;

  factory CityReferenceItem.fromJson(Map<String, dynamic> json) {
    return CityReferenceItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      countryId: (json['countryId'] as num?)?.toInt() ?? 0,
      countryName: json['countryName'] as String? ?? '',
    );
  }

  static List<CityReferenceItem> listFromJson(dynamic json) =>
      parseJsonList(json, CityReferenceItem.fromJson);
}
