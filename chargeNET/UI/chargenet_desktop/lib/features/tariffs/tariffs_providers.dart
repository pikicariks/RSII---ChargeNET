import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tariffsListProvider =
    AsyncNotifierProvider<TariffsListNotifier, PagedResponse<Tariff>>(
  TariffsListNotifier.new,
);

class TariffsListNotifier extends AsyncNotifier<PagedResponse<Tariff>> {
  int _page = 1;
  int _pageSize = 20;

  @override
  Future<PagedResponse<Tariff>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    return api.getTariffsPaged(page: _page, pageSize: _pageSize);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      return api.getTariffsPaged(page: _page, pageSize: _pageSize);
    });
  }

  Future<void> nextPage() async {
    _page += 1;
    await reload();
  }

  Future<void> previousPage() async {
    if (_page > 1) {
      _page -= 1;
      await reload();
    }
  }

  Future<void> setPageSize(int pageSize) async {
    _pageSize = pageSize;
    _page = 1;
    await reload();
  }
}
