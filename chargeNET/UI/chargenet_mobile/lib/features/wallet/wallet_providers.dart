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
  ref.invalidate(walletBalanceProvider);
  ref.invalidate(walletTransactionsProvider);
  await ref.read(walletBalanceProvider.future);
}
