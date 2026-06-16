import 'package:chargenet_desktop/features/sessions/sessions_providers.dart';
import 'package:chargenet_desktop/widgets/data_table_shell.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D3 — charging sessions table + pending reservation confirmations.
class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsListProvider);
    final filter = ref.watch(sessionsFilterProvider);
    final pending = ref.watch(pendingReservationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        pending.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pending reservations',
                  style: ChargeNetTextStyles.title(),
                ),
                const SizedBox(height: ChargeNetSpacing.sm),
                ...items.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: ChargeNetSpacing.sm,
                    ),
                    child: CnCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${r.id} · ${r.chargingStationName}',
                                  style: ChargeNetTextStyles.label(),
                                ),
                                Text(
                                  '${r.userEmail} · ${formatSessionDateTime(r.reservationStart)}',
                                  style: ChargeNetTextStyles.caption(),
                                ),
                              ],
                            ),
                          ),
                          CnButton(
                            label: 'Confirm',
                            expand: false,
                            onPressed: () => _confirmReservation(context, ref, r.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ChargeNetSpacing.lg),
              ],
            );
          },
        ),
        CnCard(
          child: Row(
            children: [
              Text('Status filter', style: ChargeNetTextStyles.bodySm()),
              const SizedBox(width: ChargeNetSpacing.md),
              DropdownButton<SessionFilter>(
                value: filter.status,
                dropdownColor: ChargeNetColors.surface,
                items: const [
                  DropdownMenuItem(
                    value: SessionFilter.all,
                    child: Text('All sessions'),
                  ),
                  DropdownMenuItem(
                    value: SessionFilter.active,
                    child: Text('Active only'),
                  ),
                  DropdownMenuItem(
                    value: SessionFilter.completed,
                    child: Text('Completed only'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(sessionsFilterProvider.notifier).setStatus(v);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: ChargeNetSpacing.md),
        sessions.when(
          loading: () => const DataTableShell<ChargingSession>(
            title: 'Charging sessions',
            columns: [],
            items: [],
            buildRow: _emptyRow,
            isLoading: true,
          ),
          error: (e, _) => DataTableShell<ChargingSession>(
            title: 'Charging sessions',
            columns: const [],
            items: const [],
            buildRow: _emptyRow,
            error: e.toString(),
            onRetry: () => ref.invalidate(sessionsListProvider),
          ),
          data: (paged) => DataTableShell<ChargingSession>(
            title: 'Charging sessions',
            searchHint: 'Search user or station…',
            onSearchChanged: (q) {
              ref.read(sessionsFilterProvider.notifier).setSearch(q);
            },
            columns: const [
              DataColumn(label: Text('User')),
              DataColumn(label: Text('Station')),
              DataColumn(label: Text('Connector')),
              DataColumn(label: Text('Started')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('kWh')),
              DataColumn(label: Text('Cost')),
            ],
            items: paged.items,
            currentPage: paged.page ?? 1,
            pageSize: paged.pageSize ?? 20,
            totalCount: paged.totalCount ?? paged.items.length,
            onPreviousPage: () => ref.read(sessionsListProvider.notifier).previousPage(),
            onNextPage: () => ref.read(sessionsListProvider.notifier).nextPage(),
            onPageSizeChanged: (size) =>
                ref.read(sessionsListProvider.notifier).setPageSize(size),
            buildRow: (s) => [
              DataCell(Text(s.userEmail)),
              DataCell(Text(s.chargingStationName)),
              DataCell(Text(s.connectorLabel)),
              DataCell(Text(formatSessionDateTime(s.startTime))),
              DataCell(CnStatusBadge(
                status: s.isActive
                    ? CnStationStatus.charging
                    : CnStationStatus.inactive,
                compact: true,
              )),
              DataCell(Text(
                s.energyConsumedKwh?.toStringAsFixed(1) ?? '—',
              )),
              DataCell(Text(
                s.cost != null ? '€${s.cost!.toStringAsFixed(2)}' : '—',
              )),
            ],
          ),
        ),
      ],
    );
  }

  static List<DataCell> _emptyRow(ChargingSession _) => [];

  Future<void> _confirmReservation(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.confirmReservation(id);
      ref.invalidate(pendingReservationsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation #$id confirmed')),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
