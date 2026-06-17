import 'dart:io';

import 'package:chargenet_desktop/features/reports/reports_providers.dart';
import 'package:chargenet_desktop/widgets/date_range_dialog.dart';
import 'package:chargenet_desktop/widgets/kpi_card.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D7 — revenue line chart + sessions per station bar chart.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(reportsDateRangeProvider);
    final reports = ref.watch(reportsDataProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: ChargeNetSpacing.sm,
          runSpacing: ChargeNetSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Reports & analytics', style: ChargeNetTextStyles.title()),
            CnButton(
              label:
                  '${formatChargeNetDate(range.start)} – ${formatChargeNetDate(range.end)}',
              variant: CnButtonVariant.secondary,
              expand: false,
              icon: Icons.date_range_outlined,
              onPressed: () async {
                final picked = await DateRangeDialog.show(
                  context,
                  initial: range,
                );
                if (picked != null) {
                  ref.read(reportsDateRangeProvider.notifier).state = picked;
                }
              },
            ),
            CnButton(
              label: 'Download Revenue PDF',
              variant: CnButtonVariant.secondary,
              expand: false,
              onPressed: () => _downloadRevenuePdf(context, ref, range),
            ),
            CnButton(
              label: 'Download Sessions PDF',
              variant: CnButtonVariant.secondary,
              expand: false,
              onPressed: () => _downloadSessionsPdf(context, ref, range),
            ),
          ],
        ),
        const SizedBox(height: ChargeNetSpacing.lg),
        reports.when(
          loading: () => const CnLoading(message: 'Loading analytics…'),
          error: (e, _) => CnErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(reportsDataProvider),
            expand: false,
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: ChargeNetSpacing.md,
                runSpacing: ChargeNetSpacing.md,
                children: [
                  SizedBox(
                    width: 260,
                    child: KpiCard(
                      label: 'Revenue',
                      value: '€${data.totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: KpiCard(
                      label: 'Energy delivered',
                      value: '${data.totalEnergyKwh.toStringAsFixed(1)} kWh',
                      icon: Icons.bolt_outlined,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: KpiCard(
                      label: 'Completed sessions',
                      value: '${data.sessions.length}',
                      icon: Icons.ev_station_outlined,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: KpiCard(
                      label: 'Invoices',
                      value: '${data.invoices.length}',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ChargeNetSpacing.lg),
              _RevenueChart(data: data),
              const SizedBox(height: ChargeNetSpacing.lg),
              _SessionsChart(data: data),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadRevenuePdf(
    BuildContext context,
    WidgetRef ref,
    ReportDateRange range,
  ) async {
    await _downloadPdf(
      context: context,
      ref: ref,
      defaultName:
          'revenue-report-${range.start.toIso8601String().substring(0, 10)}-${range.end.toIso8601String().substring(0, 10)}.pdf',
      loader: (api) => api.downloadRevenueReportPdf(
        from: range.start,
        to: range.end,
      ),
    );
  }

  Future<void> _downloadSessionsPdf(
    BuildContext context,
    WidgetRef ref,
    ReportDateRange range,
  ) async {
    await _downloadPdf(
      context: context,
      ref: ref,
      defaultName:
          'sessions-report-${range.start.toIso8601String().substring(0, 10)}-${range.end.toIso8601String().substring(0, 10)}.pdf',
      loader: (api) => api.downloadSessionsReportPdf(
        from: range.start,
        to: range.end,
      ),
    );
  }

  Future<void> _downloadPdf({
    required BuildContext context,
    required WidgetRef ref,
    required String defaultName,
    required Future<List<int>> Function(ChargeNetApi api) loader,
  }) async {
    try {
      final saveLocation = await getSaveLocation(
        suggestedName: defaultName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );
      if (saveLocation == null) {
        return;
      }

      final api = await ref.read(chargeNetApiProvider.future);
      final bytes = await loader(api);
      final file = File(saveLocation.path);
      await file.writeAsBytes(bytes, flush: true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved PDF: ${saveLocation.path}')),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save PDF: $e')),
        );
      }
    }
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.data});

  final ReportsData data;

  @override
  Widget build(BuildContext context) {
    final points = data.revenueByDay();
    if (points.isEmpty) {
      return CnCard(
        child: Text(
          'No revenue in selected range',
          style: ChargeNetTextStyles.bodySm(),
        ),
      );
    }

    final entries = points.entries.toList();
    final spots = [
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].value),
    ];

    return CnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue over time', style: ChargeNetTextStyles.label()),
          const SizedBox(height: ChargeNetSpacing.md),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: ChargeNetColors.surfaceElevated,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '€${v.toInt()}',
                        style: ChargeNetTextStyles.caption(),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (entries.length / 4).clamp(1, 999).toDouble(),
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entries[i].key.substring(5),
                            style: ChargeNetTextStyles.caption(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: ChargeNetColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ChargeNetColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsChart extends StatelessWidget {
  const _SessionsChart({required this.data});

  final ReportsData data;

  @override
  Widget build(BuildContext context) {
    final byStation = data.sessionsByStation();
    if (byStation.isEmpty) {
      return CnCard(
        child: Text(
          'No completed sessions in selected range',
          style: ChargeNetTextStyles.bodySm(),
        ),
      );
    }

    final entries = byStation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(8).toList();

    return CnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sessions per station', style: ChargeNetTextStyles.label()),
          const SizedBox(height: ChargeNetSpacing.md),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: top.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: ChargeNetColors.surfaceElevated,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: ChargeNetTextStyles.caption(),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= top.length) {
                          return const SizedBox.shrink();
                        }
                        final name = top[i].key;
                        final short = name.length > 10
                            ? '${name.substring(0, 8)}…'
                            : name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            short,
                            style: ChargeNetTextStyles.caption(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (var i = 0; i < top.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: top[i].value.toDouble(),
                          color: ChargeNetColors.primary,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
