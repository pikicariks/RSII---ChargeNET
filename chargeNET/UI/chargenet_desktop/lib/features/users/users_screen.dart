import 'package:chargenet_desktop/features/users/user_form_dialog.dart';
import 'package:chargenet_desktop/features/users/users_providers.dart';
import 'package:chargenet_desktop/widgets/data_table_shell.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D4 — users CRUD with search and role filter.
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersListProvider);
    final userFilter = ref.watch(usersFilterProvider);

    return users.when(
      loading: () => const DataTableShell<ChargeNetUser>(
        title: 'Users',
        columns: [],
        items: [],
        buildRow: _emptyRow,
        isLoading: true,
      ),
      error: (e, _) => DataTableShell<ChargeNetUser>(
        title: 'Users',
        columns: const [],
        items: const [],
        buildRow: _emptyRow,
        error: e.toString(),
        onRetry: () => ref.invalidate(usersListProvider),
      ),
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DropdownButton<int?>(
                value: userFilter.roleId,
                dropdownColor: ChargeNetColors.surface,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All roles'),
                  ),
                  ...ChargeNetLookups.roles.map(
                    (r) => DropdownMenuItem<int?>(
                      value: r.id,
                      child: Text(r.name),
                    ),
                  ),
                ],
                onChanged: (v) =>
                    ref.read(usersListProvider.notifier).setRoleFilter(v),
              ),
            ],
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          DataTableShell<ChargeNetUser>(
            title: 'Users',
            searchHint: 'Search name or email…',
            onSearchChanged: (q) =>
                ref.read(usersListProvider.notifier).search(q),
            onAdd: () => _createUser(context, ref),
            addLabel: 'Add user',
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('City')),
              DataColumn(label: Text('Created')),
              DataColumn(label: Text('Actions')),
            ],
            items: items,
            buildRow: (u) => [
              DataCell(Text(u.fullName)),
              DataCell(Text(u.email)),
              DataCell(Text(u.roleName)),
              DataCell(Text(u.cityName ?? '—')),
              DataCell(Text(formatUserDate(u.createdAt))),
              DataCell(Row(
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editUser(context, ref, u),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _deleteUser(context, ref, u),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  static List<DataCell> _emptyRow(ChargeNetUser _) => [];

  Future<void> _createUser(BuildContext context, WidgetRef ref) async {
    final body = await UserFormDialog.show(context);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.createUser(body);
      await ref.read(usersListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _editUser(
    BuildContext context,
    WidgetRef ref,
    ChargeNetUser user,
  ) async {
    final body = await UserFormDialog.show(context, user: user);
    if (body == null || !context.mounted) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.updateUser(user.id, body);
      await ref.read(usersListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteUser(
    BuildContext context,
    WidgetRef ref,
    ChargeNetUser user,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text('Soft-delete "${user.fullName}"?'),
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
      await api.deleteUser(user.id);
      await ref.read(usersListProvider.notifier).reload();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
