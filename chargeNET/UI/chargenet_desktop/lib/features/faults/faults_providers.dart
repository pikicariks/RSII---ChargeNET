import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final faultsListProvider =
    AsyncNotifierProvider<FaultsListNotifier, PagedResponse<FaultReport>>(
  FaultsListNotifier.new,
);

class FaultsListNotifier extends AsyncNotifier<PagedResponse<FaultReport>> {
  int _page = 1;
  int _pageSize = 20;

  int get currentPage => _page;
  int get currentPageSize => _pageSize;

  PagedResponse<FaultReport> _withLocalPaging(PagedResponse<FaultReport> paged) {
    return paged.copyWith(page: _page, pageSize: _pageSize);
  }

  PagedResponse<FaultReport> _sorted(PagedResponse<FaultReport> paged) {
    final items = [...paged.items];
    items.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return _withLocalPaging(
      paged.copyWith(items: items),
    );
  }

  @override
  Future<PagedResponse<FaultReport>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    final paged = await api.getFaultReportsPaged(page: _page, pageSize: _pageSize);
    return _sorted(paged);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      final paged = await api.getFaultReportsPaged(page: _page, pageSize: _pageSize);
      return _sorted(paged);
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
