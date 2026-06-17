import 'package:chargenet_mobile/features/wallet/wallet_providers.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';

/// M5 — balance, top-up presets, transaction history.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  static const _topUpAmounts = [10.0, 25.0, 50.0, 100.0];

  var _isTopUpInProgress = false;
  double? _topUpAmount;

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(walletBalanceProvider);
    final transactions = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Wallet'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isTopUpInProgress ? null : () => refreshWallet(ref),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
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
                          Text(
                            'Current balance',
                            style: ChargeNetTextStyles.bodySm(),
                          ),
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
                CnCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top up', style: ChargeNetTextStyles.title()),
                      const SizedBox(height: ChargeNetSpacing.sm),
                      Wrap(
                        spacing: ChargeNetSpacing.sm,
                        runSpacing: ChargeNetSpacing.sm,
                        children: _topUpAmounts.map((amount) {
                          final isLoading =
                              _isTopUpInProgress && _topUpAmount == amount;
                          return CnButton(
                            label: '€${amount.toStringAsFixed(0)}',
                            expand: false,
                            isLoading: isLoading,
                            onPressed: _isTopUpInProgress
                                ? null
                                : () => _topUp(amount),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: ChargeNetSpacing.sm),
                      Text(
                        'Card payments only in test mode. Pull to refresh if balance is delayed.',
                        style: ChargeNetTextStyles.caption(),
                      ),
                    ],
                  ),
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
          if (_isTopUpInProgress)
            const ModalBarrier(dismissible: false, color: Colors.black26),
        ],
      ),
    );
  }

  Future<void> _topUp(double amount) async {
    if (AppConfig.stripePublishableKey.isEmpty) {
      _showMessage(
        'Stripe publishable key is missing. Start app with '
        '--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...',
      );
      return;
    }

    setState(() {
      _isTopUpInProgress = true;
      _topUpAmount = amount;
    });

    try {
      final api = await ref.read(chargeNetApiProvider.future);
      final result = await api.topUpWallet(amount: amount);
      final clientSecret = result.clientSecret;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw const ApiException(
          message: 'Missing Stripe client secret from top-up response.',
        );
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ChargeNet',
          style: ThemeMode.dark,
          allowsDelayedPaymentMethods: false,
          paymentMethodOrder: const ['card'],
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            name: CollectionMode.never,
            email: CollectionMode.never,
            phone: CollectionMode.never,
            address: AddressCollectionMode.never,
          ),
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: ChargeNetColors.surface,
              primary: ChargeNetColors.primary,
              primaryText: ChargeNetColors.textPrimary,
              secondaryText: ChargeNetColors.textSecondary,
              componentBackground: ChargeNetColors.background,
              componentBorder: ChargeNetColors.surfaceElevated,
              componentText: ChargeNetColors.textPrimary,
              placeholderText: ChargeNetColors.textMuted,
            ),
          ),
        ),
      );

      if (!mounted) return;
      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      final synced = await api.syncTopUpPayment(result.transactionId);
      if (!mounted) return;

      if (synced.status.toLowerCase() == 'completed') {
        _showMessage('Top-up completed. Balance updated.');
      } else {
        _showMessage(
          'Payment submitted (${synced.status}). Pull to refresh in a moment.',
        );
      }
      await refreshWallet(ref);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return;
      _showMessage(e.error.localizedMessage ?? 'Stripe payment failed.');
    } on ApiException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Top-up failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTopUpInProgress = false;
          _topUpAmount = null;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
