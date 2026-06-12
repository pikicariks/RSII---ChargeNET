import 'package:chargenet_mobile/features/history/history_providers.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// M6 — past charging sessions and reservations.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => refreshHistory(ref),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sessions'),
              Tab(text: 'Reservations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SessionsTab(),
            _ReservationsTab(),
          ],
        ),
      ),
    );
  }
}

class _SessionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(historySessionsProvider);

    return RefreshIndicator(
      onRefresh: () => refreshHistory(ref),
      child: sessions.when(
        loading: () => const CnLoading(message: 'Loading sessions…'),
        error: (e, _) => ListView(
          children: [
            CnErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(historySessionsProvider),
            ),
          ],
        ),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: ChargeNetSpacing.xl),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: ChargeNetColors.textMuted,
                      ),
                      const SizedBox(height: ChargeNetSpacing.sm),
                      Text(
                        'No completed sessions yet',
                        style: ChargeNetTextStyles.bodySm(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final s = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
                child: CnCard(
                  gradientBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.chargingStationName,
                        style: ChargeNetTextStyles.label(),
                      ),
                      const SizedBox(height: ChargeNetSpacing.xs),
                      Text(
                        formatChargeNetDateTime(s.startTime),
                        style: ChargeNetTextStyles.caption(),
                      ),
                      const SizedBox(height: ChargeNetSpacing.sm),
                      Row(
                        children: [
                          CnStatusBadge(
                            status: CnStationStatus.inactive,
                            compact: true,
                          ),
                          const Spacer(),
                          if (s.energyConsumedKwh != null)
                            Text(
                              '${s.energyConsumedKwh!.toStringAsFixed(1)} kWh',
                              style: ChargeNetTextStyles.caption(),
                            ),
                          if (s.cost != null) ...[
                            const SizedBox(width: ChargeNetSpacing.sm),
                            Text(
                              '€${s.cost!.toStringAsFixed(2)}',
                              style: ChargeNetTextStyles.label(
                                color: ChargeNetColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReservationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(historyReservationsProvider);

    return RefreshIndicator(
      onRefresh: () => refreshHistory(ref),
      child: reservations.when(
        loading: () => const CnLoading(message: 'Loading reservations…'),
        error: (e, _) => ListView(
          children: [
            CnErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(historyReservationsProvider),
            ),
          ],
        ),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: ChargeNetSpacing.xl),
                Center(
                  child: Text(
                    'No reservations yet',
                    style: ChargeNetTextStyles.bodySm(),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final r = items[index];
              final status = r.isCancelled
                  ? CnStationStatus.inactive
                  : r.isConfirmed
                      ? CnStationStatus.active
                      : CnStationStatus.maintenance;
              return Padding(
                padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
                child: CnCard(
                  gradientBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.chargingStationName,
                        style: ChargeNetTextStyles.label(),
                      ),
                      const SizedBox(height: ChargeNetSpacing.xs),
                      Text(
                        '${formatChargeNetDateTime(r.reservationStart)} – '
                        '${formatChargeNetDateTime(r.reservationEnd)}',
                        style: ChargeNetTextStyles.caption(),
                      ),
                      const SizedBox(height: ChargeNetSpacing.sm),
                      Row(
                        children: [
                          CnStatusBadge(status: status, compact: true),
                          const Spacer(),
                          Text(
                            r.statusName,
                            style: ChargeNetTextStyles.caption(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
