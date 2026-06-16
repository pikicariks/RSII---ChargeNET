import 'package:chargenet_desktop/features/tariffs/tariff_form_dialog.dart';
import 'package:chargenet_desktop/features/tariffs/tariffs_providers.dart';
import 'package:chargenet_desktop/widgets/data_table_shell.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D5 — tariffs CRUD.
class TariffsScreen extends ConsumerWidget {
  const TariffsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tariffs = ref.watch(tariffsListProvider);

    return tariffs.when(
      loading: () => const DataTableShell<Tariff>(
        title: 'Tariffs',
        columns: [],
        items: [],
        buildRow: _emptyRow,
        isLoading: true,
      ),
      error: (e, _) => DataTableShell<Tariff>(
        title: 'Tariffs',
        columns: const [],
        items: const [],
        buildRow: _emptyRow,
        error: e.toString(),
        onRetry: () => ref.invalidate(tariffsListProvider),
      ),
      data: (paged) => DataTableShell<Tariff>(
        title: 'Tariffs',
        onAdd: () => _createTariff(context, ref),
        addLabel: 'Add tariff',
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Price/kWh')),
          DataColumn(label: Text('Currency')),
          DataColumn(label: Text('Active')),
          DataColumn(label: Text('Actions')),
        ],
        items: paged.items,
        currentPage: paged.page ?? 1,
        pageSize: paged.pageSize ?? 20,
        totalCount: paged.totalCount ?? paged.items.length,
        onPreviousPage: () => ref.read(tariffsListProvider.notifier).previousPage(),
        onNextPage: () => ref.read(tariffsListProvider.notifier).nextPage(),
        onPageSizeChanged: (size) =>
            ref.read(tariffsListProvider.notifier).setPageSize(size),
        buildRow: (t) {
          final symbol = t.currency == 'EUR' ? '€' : t.currency;
          return [
            DataCell(Text(t.name)),
            DataCell(Text('$symbol${t.pricePerKwh.toStringAsFixed(2)}')),
            DataCell(Text(t.currency)),
            DataCell(CnStatusBadge(
              status: t.isActive
                  ? CnStationStatus.active
                  : CnStationStatus.inactive,
              compact: true,
            )),
            DataCell(Row(
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _editTariff(context, ref, t),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _deleteTariff(context, ref, t),
                ),
              ],
            )),
          ];
        },
      ),
    );
  }

  static List<DataCell> _emptyRow(Tariff _) => [];

  Future<void> _createTariff(BuildContext context, WidgetRef ref) async {
    final body = await TariffFormDialog.show(context);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.createTariff(body);
      await ref.read(tariffsListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _editTariff(
    BuildContext context,
    WidgetRef ref,
    Tariff tariff,
  ) async {
    final body = await TariffFormDialog.show(context, tariff: tariff);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.updateTariff(tariff.id, body);
      await ref.read(tariffsListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteTariff(
    BuildContext context,
    WidgetRef ref,
    Tariff tariff,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tariff?'),
        content: Text('Remove "${tariff.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.deleteTariff(tariff.id);
      await ref.read(tariffsListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
