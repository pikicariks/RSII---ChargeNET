import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Add / edit vehicle dialog (M6 freestyle).
class VehicleFormDialog extends StatefulWidget {
  const VehicleFormDialog({super.key, this.vehicle});

  final Vehicle? vehicle;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    Vehicle? vehicle,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => VehicleFormDialog(vehicle: vehicle),
    );
  }

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _plate;
  late final TextEditingController _battery;
  int? _connectorTypeId;

  bool get isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _make = TextEditingController(text: v?.make ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _year = TextEditingController(text: v?.year?.toString() ?? '');
    _plate = TextEditingController(text: v?.licensePlate ?? '');
    _battery = TextEditingController(
      text: v?.batteryCapacity?.toString() ?? '',
    );
    _connectorTypeId = v?.connectorTypeId;
  }

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    _battery.dispose();
    super.dispose();
  }

  Map<String, dynamic> _body() => {
        'make': _make.text.trim(),
        'model': _model.text.trim(),
        if (_year.text.trim().isNotEmpty)
          'year': int.tryParse(_year.text.trim()),
        if (_plate.text.trim().isNotEmpty) 'licensePlate': _plate.text.trim(),
        if (_battery.text.trim().isNotEmpty)
          'batteryCapacity': double.tryParse(_battery.text.trim()),
        if (_connectorTypeId != null) 'connectorTypeId': _connectorTypeId,
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ChargeNetColors.surface,
      title: Text(isEdit ? 'Edit vehicle' : 'Add vehicle'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CnTextField(
                controller: _make,
                label: 'Make',
                hint: 'Tesla',
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              CnTextField(
                controller: _model,
                label: 'Model',
                hint: 'Model 3',
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              CnTextField(
                controller: _year,
                label: 'Year',
                hint: '2022',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              CnTextField(
                controller: _plate,
                label: 'License plate',
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              CnTextField(
                controller: _battery,
                label: 'Battery (kWh)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              DropdownButtonFormField<int?>(
                initialValue: _connectorTypeId,
                dropdownColor: ChargeNetColors.surface,
                decoration: const InputDecoration(labelText: 'Connector type'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Optional'),
                  ),
                  for (final t in ChargeNetLookups.connectorTypes)
                    DropdownMenuItem(value: t.id, child: Text(t.name)),
                ],
                onChanged: (v) => setState(() => _connectorTypeId = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CnButton(
          label: isEdit ? 'Save' : 'Add',
          expand: false,
          onPressed: () {
            if (_make.text.trim().isEmpty || _model.text.trim().isEmpty) {
              return;
            }
            Navigator.pop(context, _body());
          },
        ),
      ],
    );
  }
}
