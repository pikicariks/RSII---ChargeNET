import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

typedef DataTableRowBuilder<T> = List<DataCell> Function(T item);

/// Reusable admin table shell — search, loading, error, data rows (D2–D7).
class DataTableShell<T> extends StatelessWidget {
  const DataTableShell({
    super.key,
    required this.title,
    required this.columns,
    required this.items,
    required this.buildRow,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.searchHint,
    this.onSearchChanged,
    this.onAdd,
    this.addLabel = 'Add',
    this.emptyMessage = 'No records found.',
  });

  final String title;
  final List<DataColumn> columns;
  final List<T> items;
  final DataTableRowBuilder<T> buildRow;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onAdd;
  final String addLabel;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(title, style: ChargeNetTextStyles.title()),
            const Spacer(),
            if (onAdd != null)
              CnButton(
                label: addLabel,
                expand: false,
                icon: Icons.add_rounded,
                onPressed: onAdd,
              ),
          ],
        ),
        if (onSearchChanged != null) ...[
          const SizedBox(height: ChargeNetSpacing.md),
          CnTextField(
            hint: searchHint ?? 'Search…',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            onChanged: onSearchChanged,
          ),
        ],
        const SizedBox(height: ChargeNetSpacing.lg),
        if (isLoading)
          const SizedBox(height: 200, child: CnLoading())
        else if (error != null)
          CnErrorView(message: error!, onRetry: onRetry, expand: false)
        else if (items.isEmpty)
          CnCard(
            child: Text(emptyMessage, style: ChargeNetTextStyles.bodySm()),
          )
        else
          CnCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  ChargeNetColors.surfaceElevated.withValues(alpha: 0.35),
                ),
                columns: columns,
                rows: items.map((item) => DataRow(cells: buildRow(item))).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
