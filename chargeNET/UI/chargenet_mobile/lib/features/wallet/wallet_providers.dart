import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final walletBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getWalletBalance();
});

final walletTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getWalletTransactions();
});

Future<void> refreshWallet(WidgetRef ref) async {
  final api = await ref.read(chargeNetApiProvider.future);
  final transactions = await api.getWalletTransactions();

  for (final transaction in transactions) {
    final isPendingTopUp = transaction.type.toLowerCase() == 'topup' &&
        transaction.status.toLowerCase() == 'pending';
    if (!isPendingTopUp) continue;

    try {
      await api.syncTopUpPayment(transaction.id);
    } on ApiException {
      // Leave pending if Stripe has not finalized the payment yet.
    }
  }

  ref.invalidate(walletBalanceProvider);
  ref.invalidate(walletTransactionsProvider);
  await ref.read(walletBalanceProvider.future);
}
