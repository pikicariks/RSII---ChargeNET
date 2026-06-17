import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Dropdown that works inside [AlertDialog] overlays on desktop.
class CnDialogDropdown<T> extends StatelessWidget {
  const CnDialogDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: items.any((item) => item.value == value) ? value : null,
          isExpanded: true,
          dropdownColor: ChargeNetColors.surface,
          borderRadius: BorderRadius.circular(ChargeNetRadii.md),
          menuMaxHeight: 280,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
