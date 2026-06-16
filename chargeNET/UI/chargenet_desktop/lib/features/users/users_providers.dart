import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersListProvider =
    AsyncNotifierProvider<UsersListNotifier, PagedResponse<ChargeNetUser>>(
  UsersListNotifier.new,
);

class UsersFilterState {
  const UsersFilterState({this.search = '', this.roleId});

  final String search;
  final int? roleId;
}

final usersFilterProvider = Provider<UsersFilterState>((ref) {
  ref.watch(usersListProvider);
  return ref.read(usersListProvider.notifier).filter;
});

class UsersListNotifier extends AsyncNotifier<PagedResponse<ChargeNetUser>> {
  String _search = '';
  int? _roleId;
  int _page = 1;
  int _pageSize = 20;

  UsersFilterState get filter =>
      UsersFilterState(search: _search, roleId: _roleId);

  @override
  Future<PagedResponse<ChargeNetUser>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    return api.getUsersPaged(
      fullText: _search.isEmpty ? null : _search,
      roleId: _roleId,
      page: _page,
      pageSize: _pageSize,
    );
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      return api.getUsersPaged(
        fullText: _search.isEmpty ? null : _search,
        roleId: _roleId,
        page: _page,
        pageSize: _pageSize,
      );
    });
  }

  Future<void> search(String query) async {
    _search = query;
    _page = 1;
    await _reload();
  }

  Future<void> setRoleFilter(int? roleId) async {
    _roleId = roleId;
    _page = 1;
    await _reload();
  }

  Future<void> nextPage() async {
    _page += 1;
    await _reload();
  }

  Future<void> previousPage() async {
    if (_page > 1) {
      _page -= 1;
      await _reload();
    }
  }

  Future<void> setPageSize(int pageSize) async {
    _pageSize = pageSize;
    _page = 1;
    await _reload();
  }

  Future<void> reload() => _reload();
}

String formatUserDate(DateTime dt) {
  final local = dt.toLocal();
  return '${local.day}.${local.month}.${local.year}';
}
