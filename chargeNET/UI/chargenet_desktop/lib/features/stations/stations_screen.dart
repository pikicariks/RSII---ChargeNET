import 'package:chargenet_desktop/features/dashboard/dashboard_providers.dart';
import 'package:chargenet_desktop/features/stations/connector_form_dialog.dart';
import 'package:chargenet_desktop/features/stations/station_form_dialog.dart';
import 'package:chargenet_desktop/features/stations/stations_providers.dart';
import 'package:chargenet_desktop/widgets/admin_data_table.dart';
import 'package:chargenet_desktop/widgets/data_table_shell.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StationsScreen extends ConsumerWidget {
  const StationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(stationsListProvider);

    return stations.when(
      loading: () {
        final listNotifier = ref.read(stationsListProvider.notifier);
        return DataTableShell<ChargingStation>(
          title: 'Stations',
          searchHint: 'Search by name… (press Enter)',
          initialSearchQuery: listNotifier.currentSearch,
          onSearchSubmitted: (q) =>
              ref.read(stationsListProvider.notifier).search(q),
          onAdd: () => _createStation(context, ref),
          addLabel: 'Add station',
          columns: const [],
          items: const [],
          buildRow: (_) => [],
          isLoading: true,
        );
      },
      error: (e, _) => CnErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(stationsListProvider),
      ),
      data: (paged) {
        final listNotifier = ref.read(stationsListProvider.notifier);
        return DataTableShell<ChargingStation>(
        title: 'Stations',
        searchHint: 'Search by name… (press Enter)',
        initialSearchQuery: listNotifier.currentSearch,
        onSearchSubmitted: (q) =>
            ref.read(stationsListProvider.notifier).search(q),
        onAdd: () => _createStation(context, ref),
        addLabel: 'Add station',
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('City')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Connectors')),
          DataColumn(label: Text('Actions')),
        ],
        items: paged.items,
        currentPage: listNotifier.currentPage,
        pageSize: listNotifier.currentPageSize,
        totalCount: paged.totalCount ?? paged.items.length,
        onPreviousPage: () => ref.read(stationsListProvider.notifier).previousPage(),
        onNextPage: () => ref.read(stationsListProvider.notifier).nextPage(),
        onPageSizeChanged: (size) =>
            ref.read(stationsListProvider.notifier).setPageSize(size),
        buildRow: (s) => [
          DataCell(Text(s.name)),
          DataCell(Text(s.cityName)),
          DataCell(CnStatusBadge(
            status: statusBadgeFor(s.statusName),
            compact: true,
          )),
          DataCell(Text('${s.connectorCount}')),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'View',
                icon: const Icon(Icons.visibility_outlined, size: 20),
                onPressed: () => context.go('/stations/${s.id}'),
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _editStation(context, ref, s),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _deleteStation(context, ref, s),
              ),
            ],
          )),
        ],
      );
      },
    );
  }

  Future<void> _createStation(BuildContext context, WidgetRef ref) async {
    final body = await StationFormDialog.show(context);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.createStation(body);
      await ref.read(stationsListProvider.notifier).reload();
      ref.invalidate(dashboardProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _editStation(
    BuildContext context,
    WidgetRef ref,
    ChargingStation station,
  ) async {
    final body = await StationFormDialog.show(context, station: station);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.updateStation(station.id, body);
      await ref.read(stationsListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteStation(
    BuildContext context,
    WidgetRef ref,
    ChargingStation station,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete station?'),
        content: Text('Remove "${station.name}" permanently?'),
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
      await api.deleteStation(station.id);
      await ref.read(stationsListProvider.notifier).reload();
      ref.invalidate(dashboardProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({super.key, required this.stationId});

  final int stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final station = ref.watch(stationDetailProvider(stationId));
    final connectors = ref.watch(stationConnectorsProvider(stationId));

    return station.when(
      loading: () => const CnLoading(message: 'Loading station…'),
      error: (e, _) => CnErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(stationDetailProvider(stationId)),
      ),
      data: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/stations'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text(s.name, style: ChargeNetTextStyles.title()),
              const Spacer(),
              CnStatusBadge(status: statusBadgeFor(s.statusName)),
            ],
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          CnCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.address, style: ChargeNetTextStyles.body()),
                const SizedBox(height: ChargeNetSpacing.sm),
                Text(
                  '${s.cityName} · ${s.latitude?.toStringAsFixed(4)}, ${s.longitude?.toStringAsFixed(4)}',
                  style: ChargeNetTextStyles.bodySm(),
                ),
              ],
            ),
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          Row(
            children: [
              Text('Connectors', style: ChargeNetTextStyles.title()),
              const Spacer(),
              CnButton(
                label: 'Add connector',
                expand: false,
                icon: Icons.add_rounded,
                onPressed: () => _addConnector(context, ref),
              ),
            ],
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          connectors.when(
            loading: () => const CnLoading(expand: false),
            error: (e, _) => Text(e.toString()),
            data: (list) => list.isEmpty
                ? Text('No connectors yet.', style: ChargeNetTextStyles.bodySm())
                : CnCard(
                    padding: EdgeInsets.zero,
                    child: AdminDataTable(
                      columns: const [
                        DataColumn(label: Text('Label')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Power')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: list.map((c) {
                        return DataRow(cells: [
                          DataCell(Text(c.label ?? '—')),
                          DataCell(Text(c.connectorTypeName)),
                          DataCell(Text('${c.powerKw} kW')),
                          DataCell(CnStatusBadge(
                            status: c.isAvailable
                                ? CnStationStatus.active
                                : CnStationStatus.inactive,
                            compact: true,
                          )),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => _deleteConnector(context, ref, c.id),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addConnector(BuildContext context, WidgetRef ref) async {
    final body = await ConnectorFormDialog.show(context, stationId: stationId);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.createConnector(body);
      ref.invalidate(stationConnectorsProvider(stationId));
      ref.invalidate(stationDetailProvider(stationId));
      ref.invalidate(stationsListProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteConnector(
    BuildContext context,
    WidgetRef ref,
    int connectorId,
  ) async {
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.deleteConnector(connectorId);
      ref.invalidate(stationConnectorsProvider(stationId));
      ref.invalidate(stationDetailProvider(stationId));
      ref.invalidate(stationsListProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
