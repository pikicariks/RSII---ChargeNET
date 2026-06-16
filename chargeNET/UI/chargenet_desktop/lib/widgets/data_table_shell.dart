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
    this.currentPage,
    this.pageSize,
    this.totalCount,
    this.onPreviousPage,
    this.onNextPage,
    this.onPageSizeChanged,
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
  final int? currentPage;
  final int? pageSize;
  final int? totalCount;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final ValueChanged<int>? onPageSizeChanged;

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
        if (!isLoading &&
            error == null &&
            currentPage != null &&
            pageSize != null &&
            totalCount != null &&
            onPreviousPage != null &&
            onNextPage != null) ...[
          const SizedBox(height: ChargeNetSpacing.md),
          CnCard(
            child: Builder(
              builder: (context) {
                final safePageSize = pageSize! <= 0 ? 1 : pageSize!;
                final totalPages = totalCount! == 0
                    ? 1
                    : ((totalCount! + safePageSize - 1) ~/ safePageSize);
                final canGoPrevious = currentPage! > 1;
                final canGoNext = currentPage! < totalPages;
                return Row(
                  children: [
                    Text(
                      'Page $currentPage of $totalPages · ${items.length} shown · $totalCount total',
                      style: ChargeNetTextStyles.caption(),
                    ),
                    const Spacer(),
                    if (onPageSizeChanged != null)
                      DropdownButton<int>(
                        value: pageSize,
                        dropdownColor: ChargeNetColors.surface,
                        items: const [10, 20, 50, 100]
                            .map(
                              (size) => DropdownMenuItem<int>(
                                value: size,
                                child: Text('$size / page'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onPageSizeChanged!(value);
                          }
                        },
                      ),
                    const SizedBox(width: ChargeNetSpacing.sm),
                    CnButton(
                      label: 'Previous',
                      variant: CnButtonVariant.secondary,
                      expand: false,
                      onPressed: canGoPrevious ? onPreviousPage : null,
                    ),
                    const SizedBox(width: ChargeNetSpacing.sm),
                    CnButton(
                      label: 'Next',
                      variant: CnButtonVariant.secondary,
                      expand: false,
                      onPressed: canGoNext ? onNextPage : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
