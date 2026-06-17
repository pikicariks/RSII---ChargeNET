import 'package:chargenet_desktop/features/service_orders/mock_service_order.dart';
import 'package:chargenet_desktop/features/service_orders/service_orders_providers.dart';
import 'package:chargenet_desktop/widgets/data_table_shell.dart';
import 'package:chargenet_desktop/widgets/service_order_form_dialog.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D8 — service orders with static/mock data (no backend).
class ServiceOrdersScreen extends ConsumerWidget {
  const ServiceOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(mockServiceOrdersProvider);

    return DataTableShell<MockServiceOrder>(
      title: 'Service orders',
      addLabel: 'New order',
      onAdd: () => _newOrder(context, ref),
      columns: const [
        DataColumn(label: Text('Order ID')),
        DataColumn(label: Text('Station')),
        DataColumn(label: Text('Issue')),
        DataColumn(label: Text('Technician')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Scheduled')),
      ],
      items: orders,
      emptyMessage: 'No service orders — create one or assign from Faults.',
      buildRow: (o) => [
        DataCell(Text('#${o.id}')),
        DataCell(Text(o.stationName)),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              o.issue,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(o.technician)),
        DataCell(CnStatusBadge(
          status: o.status.toLowerCase().contains('progress')
              ? CnStationStatus.charging
              : CnStationStatus.maintenance,
          compact: true,
        )),
        DataCell(Text(formatChargeNetDate(o.scheduledDate))),
      ],
    );
  }

  Future<void> _newOrder(BuildContext context, WidgetRef ref) async {
    final result = await ServiceOrderFormDialog.show(context);
    if (result == null || !context.mounted) return;
    ref.read(mockServiceOrdersProvider.notifier).addOrder(
          stationName: result.stationName,
          faultReportId: result.faultReportId,
          issue: result.issue,
          technician: result.technician,
          scheduledDate: result.scheduledDate,
        );
  }
}
