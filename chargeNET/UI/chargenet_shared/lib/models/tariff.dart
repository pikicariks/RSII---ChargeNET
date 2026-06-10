import '../api/json_utils.dart';

class Tariff {
  const Tariff({
    required this.id,
    required this.name,
    required this.pricePerKwh,
    required this.currency,
    this.pricePerMinute,
    this.isActive = true,
  });

  final int id;
  final String name;
  final double pricePerKwh;
  final String currency;
  final double? pricePerMinute;
  final bool isActive;

  factory Tariff.fromJson(Map<String, dynamic> json) {
    return Tariff(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      pricePerKwh: (json['pricePerKWh'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      pricePerMinute: (json['pricePerMinute'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static List<Tariff> listFromJson(dynamic json) =>
      parseJsonList(json, Tariff.fromJson);
}
