class WalletBalance {
  const WalletBalance({
    required this.userId,
    required this.balance,
    required this.currency,
  });

  final int userId;
  final double balance;
  final String currency;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
    );
  }
}

class WalletTopUpResult {
  const WalletTopUpResult({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.status,
    this.clientSecret,
  });

  final int transactionId;
  final double amount;
  final String currency;
  final String status;
  final String? clientSecret;

  factory WalletTopUpResult.fromJson(Map<String, dynamic> json) {
    return WalletTopUpResult(
      transactionId: (json['transactionId'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      status: json['status'] as String? ?? '',
      clientSecret: json['clientSecret'] as String?,
    );
  }
}
