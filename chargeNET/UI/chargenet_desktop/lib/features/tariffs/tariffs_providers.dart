import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tariffsListProvider =
    AsyncNotifierProvider<TariffsListNotifier, List<Tariff>>(
  TariffsListNotifier.new,
);

class TariffsListNotifier extends AsyncNotifier<List<Tariff>> {
  @override
  Future<List<Tariff>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    return api.getTariffs();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      return api.getTariffs();
    });
  }
}
