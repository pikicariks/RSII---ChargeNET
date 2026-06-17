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

  int get currentPage => _page;
  int get currentPageSize => _pageSize;
  String get currentSearch => _search;

  UsersFilterState get filter =>
      UsersFilterState(search: _search, roleId: _roleId);

  Future<PagedResponse<ChargeNetUser>> _load() async {
    final api = await ref.read(chargeNetApiProvider.future);
    final all = await api.getUsers(
      roleId: _roleId,
      pageSize: 100,
    );

    var filtered = all;
    final query = _search.trim();
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = all
          .where(
            (u) =>
                u.fullName.toLowerCase().contains(q) ||
                u.email.toLowerCase().contains(q),
          )
          .toList();
    }

    return PagedResponse<ChargeNetUser>(
      items: filtered,
      totalCount: filtered.length,
    ).applyPage(page: _page, pageSize: _pageSize);
  }

  @override
  Future<PagedResponse<ChargeNetUser>> build() async {
    ref.watch(chargeNetApiProvider.future);
    return _load();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> search(String query) async {
    _search = query.trim();
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
