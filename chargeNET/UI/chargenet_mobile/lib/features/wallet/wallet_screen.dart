import 'package:chargenet_mobile/features/wallet/wallet_providers.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// M5 — balance, top-up presets, transaction history.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const _topUpAmounts = [10.0, 25.0, 50.0, 100.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletBalanceProvider);
    final transactions = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Wallet'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => refreshWallet(ref),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshWallet(ref),
        child: ListView(
          padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
          children: [
            balance.when(
              loading: () => const CnLoading(message: 'Loading balance…'),
              error: (e, _) => CnErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(walletBalanceProvider),
                expand: false,
              ),
              data: (b) {
                final symbol = b.currency == 'EUR' ? '€' : b.currency;
                return CnCard(
                  gradientBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current balance', style: ChargeNetTextStyles.bodySm()),
                      const SizedBox(height: ChargeNetSpacing.sm),
                      Text(
                        '$symbol${b.balance.toStringAsFixed(2)}',
                        style: ChargeNetTextStyles.heading(
                          color: ChargeNetColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: ChargeNetSpacing.lg),
            Text('Top up', style: ChargeNetTextStyles.title()),
            const SizedBox(height: ChargeNetSpacing.sm),
            Wrap(
              spacing: ChargeNetSpacing.sm,
              runSpacing: ChargeNetSpacing.sm,
              children: _topUpAmounts.map((amount) {
                return CnButton(
                  label: '€${amount.toStringAsFixed(0)}',
                  expand: false,
                  onPressed: () => _topUp(context, ref, amount),
                );
              }).toList(),
            ),
            const SizedBox(height: ChargeNetSpacing.xs),
            Text(
              'Requires Stripe in Docker. After payment, pull to refresh balance.',
              style: ChargeNetTextStyles.caption(),
            ),
            const SizedBox(height: ChargeNetSpacing.lg),
            Text('Transactions', style: ChargeNetTextStyles.title()),
            const SizedBox(height: ChargeNetSpacing.sm),
            transactions.when(
              loading: () => const CnLoading(expand: false),
              error: (e, _) => CnErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(walletTransactionsProvider),
                expand: false,
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Text(
                    'No transactions yet.',
                    style: ChargeNetTextStyles.bodySm(),
                  );
                }
                return Column(
                  children: [
                    for (final t in items) _TransactionTile(transaction: t),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _topUp(
    BuildContext context,
    WidgetRef ref,
    double amount,
  ) async {
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      final result = await api.topUpWallet(amount: amount);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Top-up initiated (${result.status}). '
            'Complete payment in Stripe test mode, then refresh.',
          ),
        ),
      );
      await refreshWallet(ref);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.toLowerCase().contains('top');
    final color = isCredit ? ChargeNetColors.primary : ChargeNetColors.warning;
    final prefix = isCredit ? '+' : '−';
    final symbol = transaction.currency == 'EUR' ? '€' : transaction.currency;

    return Padding(
      padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
      child: CnCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.type, style: ChargeNetTextStyles.label()),
                  Text(
                    transaction.status,
                    style: ChargeNetTextStyles.caption(),
                  ),
                ],
              ),
            ),
            Text(
              '$prefix$symbol${transaction.amount.abs().toStringAsFixed(2)}',
              style: ChargeNetTextStyles.label(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
