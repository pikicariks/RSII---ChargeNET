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
      data: (paged) => DataTableShell<FaultReport>(
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
        currentPage: paged.page ?? 1,
        pageSize: paged.pageSize ?? 20,
        totalCount: paged.totalCount ?? paged.items.length,
        onPreviousPage: () => ref.read(faultsListProvider.notifier).previousPage(),
        onNextPage: () => ref.read(faultsListProvider.notifier).nextPage(),
        onPageSizeChanged: (size) =>
            ref.read(faultsListProvider.notifier).setPageSize(size),
        buildRow: (f) => [
          DataCell(Text(f.chargingStationName)),
          DataCell(Text(f.userEmail)),
          DataCell(
            SizedBox(
              width: 240,
              child: Text(
                f.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          DataCell(Text(f.isResolved ? 'Resolved' : 'Open')),
          DataCell(Text(formatChargeNetDateTime(f.reportedAt))),
          DataCell(Row(
            children: [
              if (!f.isResolved)
                TextButton(
                  onPressed: () => _resolve(context, ref, f.id),
                  child: const Text('Resolve'),
                )
              else
                TextButton(
                  onPressed: () => _reopen(context, ref, f.id),
                  child: const Text('Reopen'),
                ),
              TextButton(
                onPressed: () => _createServiceOrder(context, ref, f),
                child: const Text('Service order'),
              ),
            ],
          )),
        ],
      ),
    );
  }

  static List<DataCell> _emptyRow(FaultReport _) => [];

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
