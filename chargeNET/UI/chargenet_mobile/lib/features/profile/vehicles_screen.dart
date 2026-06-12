import 'package:chargenet_mobile/features/profile/profile_providers.dart';
import 'package:chargenet_mobile/features/profile/vehicle_form_dialog.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// M6 — vehicle CRUD for the signed-in driver.
class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('My vehicles'),
        actions: [
          IconButton(
            tooltip: 'Add vehicle',
            onPressed: () => _addVehicle(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: vehicles.when(
        loading: () => const CnLoading(message: 'Loading vehicles…'),
        error: (e, _) => CnErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(vehiclesListProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No vehicles yet',
                    style: ChargeNetTextStyles.bodySm(),
                  ),
                  const SizedBox(height: ChargeNetSpacing.md),
                  CnButton(
                    label: 'Add vehicle',
                    expand: false,
                    onPressed: () => _addVehicle(context, ref),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final v = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
                child: CnCard(
                  gradientBorder: true,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.displayName, style: ChargeNetTextStyles.label()),
                            if (v.licensePlate != null)
                              Text(
                                v.licensePlate!,
                                style: ChargeNetTextStyles.caption(),
                              ),
                            if (v.connectorTypeName != null)
                              Text(
                                v.connectorTypeName!,
                                style: ChargeNetTextStyles.caption(),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => _editVehicle(context, ref, v),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _deleteVehicle(context, ref, v),
                        icon: const Icon(Icons.delete_outline, size: 20),
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

  Future<void> _addVehicle(BuildContext context, WidgetRef ref) async {
    final body = await VehicleFormDialog.show(context);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.createVehicle(body);
      await ref.read(vehiclesListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _editVehicle(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final body = await VehicleFormDialog.show(context, vehicle: vehicle);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.updateVehicle(vehicle.id, body);
      await ref.read(vehiclesListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteVehicle(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete vehicle?'),
        content: Text('Remove ${vehicle.displayName}?'),
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
      await api.deleteVehicle(vehicle.id);
      await ref.read(vehiclesListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
