import '../api/json_utils.dart';

class Invoice {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.userEmail,
    required this.invoiceDate,
    required this.totalAmount,
    required this.currency,
    required this.status,
  });

  final int id;
  final String invoiceNumber;
  final String userEmail;
  final DateTime invoiceDate;
  final double totalAmount;
  final String currency;
  final String status;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: (json['id'] as num?)?.toInt() ?? 0,
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      status: json['status'] as String? ?? '',
    );
  }

  static List<Invoice> listFromJson(dynamic json) =>
      parseJsonList(json, Invoice.fromJson);
}
