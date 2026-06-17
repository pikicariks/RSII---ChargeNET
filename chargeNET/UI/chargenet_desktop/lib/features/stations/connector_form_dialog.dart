import 'package:chargenet_desktop/features/reference_data/reference_data_providers.dart';
import 'package:chargenet_desktop/widgets/cn_dialog_dropdown.dart';
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
    // Root navigator avoids height constraints from the admin scroll shell.
    return showDialog<Map<String, dynamic>>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) => ConnectorFormDialog(stationId: stationId),
    );
  }

  @override
  ConsumerState<ConnectorFormDialog> createState() =>
      _ConnectorFormDialogState();
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
    final lookups = lookupAsync.asData?.value;
    final connectorTypes = connectorFormTypes(lookups);
    if (connectorTypes.isNotEmpty &&
        !connectorTypes.any((x) => x.id == _typeId)) {
      _typeId = connectorTypes.first.id;
    }

    return Dialog(
      backgroundColor: ChargeNetColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChargeNetRadii.xl),
      ),
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(ChargeNetSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add connector', style: ChargeNetTextStyles.title()),
              const SizedBox(height: ChargeNetSpacing.lg),
              CnDialogDropdown<int>(
                label: 'Type',
                value: _typeId,
                items: connectorTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _typeId = v);
                },
              ),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(controller: _label, label: 'Label (optional)'),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(
                controller: _power,
                label: 'Power (kW)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: ChargeNetSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text('Available', style: ChargeNetTextStyles.body()),
                  ),
                  Switch(
                    value: _available,
                    activeThumbColor: ChargeNetColors.primary,
                    onChanged: (v) => setState(() => _available = v),
                  ),
                ],
              ),
              const SizedBox(height: ChargeNetSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: ChargeNetSpacing.sm),
                  CnButton(
                    label: 'Add',
                    expand: false,
                    onPressed: lookupAsync.isLoading
                        ? null
                        : () => Navigator.pop(context, {
                              'chargingStationId': widget.stationId,
                              'connectorTypeId': _typeId,
                              'label': _label.text.trim().isEmpty
                                  ? null
                                  : _label.text.trim(),
                              'powerKW':
                                  double.tryParse(_power.text.trim()) ?? 22,
                              'isAvailable': _available,
                            }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
