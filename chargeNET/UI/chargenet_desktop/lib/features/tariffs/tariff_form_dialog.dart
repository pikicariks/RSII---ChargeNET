import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Add / edit tariff dialog (D-freestyle-tariff).
class TariffFormDialog extends StatefulWidget {
  const TariffFormDialog({super.key, this.tariff});

  final Tariff? tariff;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    Tariff? tariff,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TariffFormDialog(tariff: tariff),
    );
  }

  @override
  State<TariffFormDialog> createState() => _TariffFormDialogState();
}

class _TariffFormDialogState extends State<TariffFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _priceKwh;
  late final TextEditingController _priceMin;
  late final TextEditingController _currency;
  late bool _isActive;

  bool get isEdit => widget.tariff != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tariff;
    _name = TextEditingController(text: t?.name ?? '');
    _priceKwh = TextEditingController(
      text: t?.pricePerKwh.toString() ?? '0.25',
    );
    _priceMin = TextEditingController(
      text: t?.pricePerMinute?.toString() ?? '',
    );
    _currency = TextEditingController(text: t?.currency ?? 'EUR');
    _isActive = t?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _priceKwh.dispose();
    _priceMin.dispose();
    _currency.dispose();
    super.dispose();
  }

  Map<String, dynamic> _body() => {
        'name': _name.text.trim(),
        'pricePerKWh': double.tryParse(_priceKwh.text.trim()) ?? 0,
        'currency': _currency.text.trim().isEmpty ? 'EUR' : _currency.text.trim(),
        'isActive': _isActive,
        if (_priceMin.text.trim().isNotEmpty)
          'pricePerMinute': double.tryParse(_priceMin.text.trim()),
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ChargeNetColors.surface,
      title: Text(isEdit ? 'Edit tariff' : 'Add tariff'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CnTextField(controller: _name, label: 'Name'),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(
                controller: _priceKwh,
                label: 'Price per kWh',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(
                controller: _priceMin,
                label: 'Price per minute (optional)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: ChargeNetSpacing.md),
              CnTextField(controller: _currency, label: 'Currency'),
              const SizedBox(height: ChargeNetSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Active', style: ChargeNetTextStyles.bodySm()),
                value: _isActive,
                activeThumbColor: ChargeNetColors.primary,
                onChanged: (v) => setState(() => _isActive = v),
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
          label: isEdit ? 'Save' : 'Create',
          expand: false,
          onPressed: () => Navigator.pop(context, _body()),
        ),
      ],
    );
  }
}
