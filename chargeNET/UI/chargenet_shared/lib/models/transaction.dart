import '../api/json_utils.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final double amount;
  final String currency;
  final String type;
  final String status;
  final DateTime createdAt;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static List<Transaction> listFromJson(dynamic json) =>
      parseJsonList(json, Transaction.fromJson);
}
