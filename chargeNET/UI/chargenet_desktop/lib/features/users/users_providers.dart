import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersListProvider =
    AsyncNotifierProvider<UsersListNotifier, List<ChargeNetUser>>(
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

class UsersListNotifier extends AsyncNotifier<List<ChargeNetUser>> {
  String _search = '';
  int? _roleId;

  UsersFilterState get filter =>
      UsersFilterState(search: _search, roleId: _roleId);

  @override
  Future<List<ChargeNetUser>> build() async {
    final api = await ref.watch(chargeNetApiProvider.future);
    return api.getUsers(
      fullText: _search.isEmpty ? null : _search,
      roleId: _roleId,
    );
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(chargeNetApiProvider.future);
      return api.getUsers(
        fullText: _search.isEmpty ? null : _search,
        roleId: _roleId,
      );
    });
  }

  Future<void> search(String query) async {
    _search = query;
    await _reload();
  }

  Future<void> setRoleFilter(int? roleId) async {
    _roleId = roleId;
    await _reload();
  }

  Future<void> reload() => _reload();
}

String formatUserDate(DateTime dt) {
  final local = dt.toLocal();
  return '${local.day}.${local.month}.${local.year}';
}
