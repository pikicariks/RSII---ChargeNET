import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final vehiclesListProvider =
    AsyncNotifierProvider<VehiclesListNotifier, List<Vehicle>>(
  VehiclesListNotifier.new,
);

class VehiclesListNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    return api.getVehicles();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      return api.getVehicles();
    });
  }
}
