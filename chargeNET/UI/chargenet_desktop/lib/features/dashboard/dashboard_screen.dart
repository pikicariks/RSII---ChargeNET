import 'package:chargenet_desktop/features/dashboard/dashboard_providers.dart';
import 'package:chargenet_desktop/widgets/kpi_card.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _eur(double value) => '€${value.toStringAsFixed(2)}';

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '${local.day}.${local.month}.${local.year} $h:$m';
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return dashboard.when(
      loading: () => const CnLoading(message: 'Loading dashboard…'),
      error: (e, _) => CnErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(dashboardProvider),
      ),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              KpiCard(
                label: 'Total Stations',
                value: '${data.totalStations}',
                icon: Icons.ev_station_outlined,
              ),
              const SizedBox(width: ChargeNetSpacing.md),
              KpiCard(
                label: 'Active Sessions',
                value: '${data.activeSessions}',
                icon: Icons.bolt_outlined,
              ),
              const SizedBox(width: ChargeNetSpacing.md),
              KpiCard(
                label: 'Revenue Today',
                value: _eur(data.revenueToday),
                icon: Icons.payments_outlined,
                subtitle: 'Month: ${_eur(data.revenueMonth)}',
              ),
              const SizedBox(width: ChargeNetSpacing.md),
              KpiCard(
                label: 'Open Faults',
                value: '${data.openFaults}',
                icon: Icons.warning_amber_outlined,
              ),
            ],
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          Text('Recent Sessions', style: ChargeNetTextStyles.title()),
          const SizedBox(height: ChargeNetSpacing.md),
          if (data.recentSessions.isEmpty)
            CnCard(
              child: Text(
                'No sessions yet.',
                style: ChargeNetTextStyles.bodySm(),
              ),
            )
          else
            CnCard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Station')),
                    DataColumn(label: Text('Started')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Cost')),
                  ],
                  rows: data.recentSessions.map((s) {
                    return DataRow(
                      cells: [
                        DataCell(Text(s.userEmail)),
                        DataCell(Text(s.chargingStationName)),
                        DataCell(Text(_formatDateTime(s.startTime))),
                        DataCell(
                          CnStatusBadge(
                            status: s.isActive
                                ? CnStationStatus.charging
                                : CnStationStatus.inactive,
                            compact: true,
                          ),
                        ),
                        DataCell(Text(
                          s.cost != null ? _eur(s.cost!) : '—',
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
