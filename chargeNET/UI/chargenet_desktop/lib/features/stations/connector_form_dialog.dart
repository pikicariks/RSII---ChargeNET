import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

class ConnectorFormDialog extends StatefulWidget {
  const ConnectorFormDialog({super.key, required this.stationId});

  final int stationId;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required int stationId,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ConnectorFormDialog(stationId: stationId),
    );
  }

  @override
  State<ConnectorFormDialog> createState() => _ConnectorFormDialogState();
}

class _ConnectorFormDialogState extends State<ConnectorFormDialog> {
  final _label = TextEditingController();
  final _power = TextEditingController(text: '22');
  var _typeId = 1;
  var _available = true;

  @override
  void dispose() {
    _label.dispose();
    _power.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ChargeNetColors.surface,
      title: const Text('Add connector'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
                initialValue: _typeId,
              dropdownColor: ChargeNetColors.surface,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ChargeNetLookups.connectorTypes
                  .map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.name),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _typeId = v ?? 1),
            ),
            const SizedBox(height: ChargeNetSpacing.md),
            CnTextField(controller: _label, label: 'Label (optional)'),
            const SizedBox(height: ChargeNetSpacing.md),
            CnTextField(
              controller: _power,
              label: 'Power (kW)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SwitchListTile(
              title: const Text('Available'),
              value: _available,
              onChanged: (v) => setState(() => _available = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CnButton(
          label: 'Add',
          expand: false,
          onPressed: () => Navigator.pop(context, {
            'chargingStationId': widget.stationId,
            'connectorTypeId': _typeId,
            'label': _label.text.trim().isEmpty ? null : _label.text.trim(),
            'powerKW': double.tryParse(_power.text.trim()) ?? 22,
            'isAvailable': _available,
          }),
        ),
      ],
    );
  }
}
