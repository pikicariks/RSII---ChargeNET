import 'package:chargenet_desktop/features/reference_data/reference_data_providers.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add / edit user dialog (D-freestyle-user).
class UserFormDialog extends ConsumerStatefulWidget {
  const UserFormDialog({super.key, this.user});

  final ChargeNetUser? user;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    ChargeNetUser? user,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
  }

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _phone;
  late int _roleId;
  late int? _cityId;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _firstName = TextEditingController(text: u?.firstName ?? '');
    _lastName = TextEditingController(text: u?.lastName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _password = TextEditingController();
    _phone = TextEditingController(text: u?.phoneNumber ?? '');
    _roleId = u?.roleId ?? 3;
    _cityId = u?.cityId ?? 1;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Map<String, dynamic> _body() {
    if (isEdit) {
      return {
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phoneNumber': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        'roleId': _roleId,
        'cityId': _cityId,
        if (_password.text.isNotEmpty) 'password': _password.text,
      };
    }
    return {
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
      'phoneNumber': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'roleId': _roleId,
      'cityId': _cityId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final lookupAsync = ref.watch(desktopReferenceDataProvider);
    final lookups = lookupAsync.asData?.value;
    final roles = lookups?.roles ?? const <ReferenceItem>[];
    final cities = lookups?.cities ?? const <CityReferenceItem>[];
    if (roles.isNotEmpty && !roles.any((r) => r.id == _roleId)) {
      _roleId = roles.first.id;
    }
    if (cities.isNotEmpty && _cityId != null && !cities.any((c) => c.id == _cityId)) {
      _cityId = cities.first.id;
    }

    return AlertDialog(
      backgroundColor: ChargeNetColors.surface,
      title: Text(isEdit ? 'Edit user' : 'Add user'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CnTextField(controller: _firstName, label: 'First name'),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(controller: _lastName, label: 'Last name'),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(controller: _email, label: 'Email'),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(
                controller: _password,
                label: isEdit ? 'New password (optional)' : 'Password',
                obscureText: true,
              ),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(controller: _phone, label: 'Phone'),
              const SizedBox(height: ChargeNetSpacing.md),
              DropdownButtonFormField<int>(
                initialValue: _roleId,
                dropdownColor: ChargeNetColors.surface,
                decoration: const InputDecoration(labelText: 'Role'),
                items: roles
                    .map(
                      (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _roleId = v ?? 3),
              ),
              const SizedBox(height: ChargeNetSpacing.md),
              DropdownButtonFormField<int>(
                initialValue: _cityId,
                dropdownColor: ChargeNetColors.surface,
                decoration: const InputDecoration(labelText: 'City'),
                items: cities
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _cityId = v),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CnButton(
          label: isEdit ? 'Save' : 'Create',
          expand: false,
          onPressed: lookupAsync.isLoading ? null : () => Navigator.pop(context, _body()),
        ),
      ],
    );
  }
}
