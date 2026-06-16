import 'package:chargenet_desktop/features/reference_data/reference_data_providers.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectorFormDialog extends ConsumerStatefulWidget {
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
  ConsumerState<ConnectorFormDialog> createState() => _ConnectorFormDialogState();
}

class _ConnectorFormDialogState extends ConsumerState<ConnectorFormDialog> {
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
    final lookupAsync = ref.watch(desktopReferenceDataProvider);
    final connectorTypes = lookupAsync.asData?.value.connectorTypes ?? const <ReferenceItem>[];
    if (connectorTypes.isNotEmpty && !connectorTypes.any((x) => x.id == _typeId)) {
      _typeId = connectorTypes.first.id;
    }

    return AlertDialog(
      backgroundColor: ChargeNetColors.surface,
      title: const Text('Add connector'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
                initialValue: _typeId,
              dropdownColor: ChargeNetColors.surface,
              decoration: const InputDecoration(labelText: 'Type'),
              items: connectorTypes
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
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CnButton(
          label: 'Add',
          expand: false,
          onPressed: lookupAsync.isLoading
              ? null
              : () => Navigator.pop(context, {
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
