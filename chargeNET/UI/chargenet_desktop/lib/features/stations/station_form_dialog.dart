import 'package:chargenet_desktop/features/reference_data/reference_data_providers.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add / edit station dialog (D-freestyle-station).
class StationFormDialog extends ConsumerStatefulWidget {
  const StationFormDialog({super.key, this.station});

  final ChargingStation? station;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    ChargingStation? station,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StationFormDialog(station: station),
    );
  }

  @override
  ConsumerState<StationFormDialog> createState() => _StationFormDialogState();
}

class _StationFormDialogState extends ConsumerState<StationFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late int _cityId;
  late int _statusId;

  bool get isEdit => widget.station != null;

  @override
  void initState() {
    super.initState();
    final s = widget.station;
    _name = TextEditingController(text: s?.name ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _lat = TextEditingController(text: s?.latitude?.toString() ?? '43.8563');
    _lng = TextEditingController(text: s?.longitude?.toString() ?? '18.4131');
    _cityId = s?.cityId ?? 1;
    _statusId = s?.statusId ?? 1;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Map<String, dynamic> _body() => {
        'name': _name.text.trim(),
        'address': _address.text.trim(),
        'cityId': _cityId,
        'statusId': _statusId,
        'latitude': double.tryParse(_lat.text.trim()),
        'longitude': double.tryParse(_lng.text.trim()),
        'isFastCharger': false,
      };

  @override
  Widget build(BuildContext context) {
    final lookupAsync = ref.watch(desktopReferenceDataProvider);
    final lookups = lookupAsync.asData?.value;
    final cities = lookups?.cities ?? const <CityReferenceItem>[];
    final statuses = lookups?.stationStatuses ?? const <ReferenceItem>[];
    if (cities.isNotEmpty && !cities.any((c) => c.id == _cityId)) {
      _cityId = cities.first.id;
    }
    if (statuses.isNotEmpty && !statuses.any((s) => s.id == _statusId)) {
      _statusId = statuses.first.id;
    }

    return AlertDialog(
      backgroundColor: ChargeNetColors.surface,
      title: Text(isEdit ? 'Edit station' : 'Add station'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CnTextField(controller: _name, label: 'Name'),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(controller: _address, label: 'Address'),
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
                onChanged: (v) => setState(() => _cityId = v ?? _cityId),
              ),
              const SizedBox(height: ChargeNetSpacing.md),
              DropdownButtonFormField<int>(
                initialValue: _statusId,
                dropdownColor: ChargeNetColors.surface,
                decoration: const InputDecoration(labelText: 'Status'),
                items: statuses
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _statusId = v ?? _statusId),
              ),
              const SizedBox(height: ChargeNetSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CnTextField(
                      controller: _lat,
                      label: 'Latitude',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: ChargeNetSpacing.md),
                  Expanded(
                    child: CnTextField(
                      controller: _lng,
                      label: 'Longitude',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                ],
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    );
  }
}
