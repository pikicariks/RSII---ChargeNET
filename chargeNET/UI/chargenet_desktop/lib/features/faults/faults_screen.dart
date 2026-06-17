import 'package:chargenet_desktop/features/faults/faults_providers.dart';
import 'package:chargenet_desktop/features/service_orders/service_orders_providers.dart';
import 'package:chargenet_desktop/widgets/data_table_shell.dart';
import 'package:chargenet_desktop/widgets/service_order_form_dialog.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D6 — fault reports list + status update + mock service order.
class FaultsScreen extends ConsumerWidget {
  const FaultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faults = ref.watch(faultsListProvider);

    return faults.when(
      loading: () => const DataTableShell<FaultReport>(
        title: 'Fault reports',
        columns: [],
        items: [],
        buildRow: _emptyRow,
        isLoading: true,
      ),
      error: (e, _) => DataTableShell<FaultReport>(
        title: 'Fault reports',
        columns: const [],
        items: const [],
        buildRow: _emptyRow,
        error: e.toString(),
        onRetry: () => ref.invalidate(faultsListProvider),
      ),
      data: (paged) {
        final listNotifier = ref.read(faultsListProvider.notifier);
        return DataTableShell<FaultReport>(
        title: 'Fault reports',
        columns: const [
          DataColumn(label: Text('Station')),
          DataColumn(label: Text('Reporter')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Reported')),
          DataColumn(label: Text('Actions')),
        ],
        items: paged.items,
        currentPage: listNotifier.currentPage,
        pageSize: listNotifier.currentPageSize,
        totalCount: paged.totalCount ?? paged.items.length,
        onPreviousPage: () => ref.read(faultsListProvider.notifier).previousPage(),
        onNextPage: () => ref.read(faultsListProvider.notifier).nextPage(),
        onPageSizeChanged: (size) =>
            ref.read(faultsListProvider.notifier).setPageSize(size),
        buildRow: (f) => [
          DataCell(
            Text(
              f.chargingStationName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Text(
              f.userEmail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Text(
              f.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(Text(f.isResolved ? 'Resolved' : 'Open')),
          DataCell(Text(formatChargeNetDateTime(f.reportedAt))),
          DataCell(
            Wrap(
              spacing: ChargeNetSpacing.xs,
              runSpacing: ChargeNetSpacing.xs,
              children: [
                if (!f.isResolved)
                  _actionButton(
                    label: 'Resolve',
                    onPressed: () => _resolve(context, ref, f.id),
                  )
                else
                  _actionButton(
                    label: 'Reopen',
                    onPressed: () => _reopen(context, ref, f.id),
                  ),
                _actionButton(
                  label: 'Service order',
                  onPressed: () => _createServiceOrder(context, ref, f),
                ),
              ],
            ),
          ),
        ],
      );
      },
    );
  }

  static List<DataCell> _emptyRow(FaultReport _) => [];

  static Widget _actionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref, int id) async {
    try {
      await ref.read(faultsListProvider.notifier).setResolved(id, resolved: true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fault #$id marked resolved')),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _reopen(BuildContext context, WidgetRef ref, int id) async {
    try {
      await ref.read(faultsListProvider.notifier).setResolved(id, resolved: false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fault #$id reopened')),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _createServiceOrder(
    BuildContext context,
    WidgetRef ref,
    FaultReport fault,
  ) async {
    final result = await ServiceOrderFormDialog.show(
      context,
      stationName: fault.chargingStationName,
      faultReportId: fault.id,
      issue: fault.description,
    );
    if (result == null || !context.mounted) return;
    ref.read(mockServiceOrdersProvider.notifier).addOrder(
          stationName: result.stationName,
          faultReportId: result.faultReportId,
          issue: result.issue,
          technician: result.technician,
          scheduledDate: result.scheduledDate,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock service order created')),
    );
  }
}
