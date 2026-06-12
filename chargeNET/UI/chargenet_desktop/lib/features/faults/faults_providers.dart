import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final faultsListProvider =
    AsyncNotifierProvider<FaultsListNotifier, List<FaultReport>>(
  FaultsListNotifier.new,
);

class FaultsListNotifier extends AsyncNotifier<List<FaultReport>> {
  @override
  Future<List<FaultReport>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    final items = await api.getFaultReports();
    items.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return items;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      final items = await api.getFaultReports();
      items.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      return items;
    });
  }

  Future<void> setResolved(int id, {required bool resolved}) async {
    final api = await ref.read(chargeNetApiProvider.future);
    await api.updateFaultReport(id, {
      'isResolved': resolved,
      if (resolved) 'resolvedAt': DateTime.now().toUtc().toIso8601String(),
      if (!resolved) 'clearResolvedAt': true,
    });
    await reload();
  }
}
