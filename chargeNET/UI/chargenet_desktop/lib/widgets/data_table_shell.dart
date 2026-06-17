import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

import 'admin_data_table.dart';

typedef DataTableRowBuilder<T> = List<DataCell> Function(T item);

/// Reusable admin table shell — search, loading, error, data rows (D2–D7).
class DataTableShell<T> extends StatefulWidget {
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
    this.initialSearchQuery,
    this.onSearchSubmitted,
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
  final String? initialSearchQuery;
  final ValueChanged<String>? onSearchSubmitted;
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
  State<DataTableShell<T>> createState() => _DataTableShellState<T>();
}

class _DataTableShellState<T> extends State<DataTableShell<T>> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialSearchQuery ?? '');
  }

  @override
  void didUpdateWidget(DataTableShell<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextQuery = widget.initialSearchQuery ?? '';
    final prevQuery = oldWidget.initialSearchQuery ?? '';
    if (nextQuery != prevQuery && nextQuery != _searchController.text) {
      _searchController.text = nextQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    widget.onSearchSubmitted?.call(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(widget.title, style: ChargeNetTextStyles.title()),
            const Spacer(),
            if (widget.onAdd != null)
              CnButton(
                label: widget.addLabel,
                expand: false,
                icon: Icons.add_rounded,
                onPressed: widget.onAdd,
              ),
          ],
        ),
        if (widget.onSearchSubmitted != null) ...[
          const SizedBox(height: ChargeNetSpacing.md),
          CnTextField(
            controller: _searchController,
            hint: widget.searchHint ?? 'Search… (press Enter)',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submitSearch(),
          ),
        ],
        const SizedBox(height: ChargeNetSpacing.lg),
        if (widget.isLoading)
          const SizedBox(height: 200, child: CnLoading())
        else if (widget.error != null)
          CnErrorView(
            message: widget.error!,
            onRetry: widget.onRetry,
            expand: false,
          )
        else if (widget.items.isEmpty)
          CnCard(
            child: Text(widget.emptyMessage, style: ChargeNetTextStyles.bodySm()),
          )
        else
          CnCard(
            padding: EdgeInsets.zero,
            child: AdminDataTable(
              headingRowColor: WidgetStateProperty.all(
                ChargeNetColors.surfaceElevated.withValues(alpha: 0.35),
              ),
              columns: widget.columns,
              rows: widget.items
                  .map((item) => DataRow(cells: widget.buildRow(item)))
                  .toList(),
            ),
          ),
        if (!widget.isLoading &&
            widget.error == null &&
            widget.currentPage != null &&
            widget.pageSize != null &&
            widget.totalCount != null &&
            widget.onPreviousPage != null &&
            widget.onNextPage != null) ...[
          const SizedBox(height: ChargeNetSpacing.md),
          CnCard(
            child: Builder(
              builder: (context) {
                final safePageSize =
                    widget.pageSize! <= 0 ? 1 : widget.pageSize!;
                final totalPages = widget.totalCount! == 0
                    ? 1
                    : ((widget.totalCount! + safePageSize - 1) ~/ safePageSize);
                final canGoPrevious = widget.currentPage! > 1;
                final canGoNext = widget.currentPage! < totalPages;
                return Row(
                  children: [
                    Text(
                      'Page ${widget.currentPage} of $totalPages · ${widget.items.length} shown · ${widget.totalCount} total',
                      style: ChargeNetTextStyles.caption(),
                    ),
                    const Spacer(),
                    if (widget.onPageSizeChanged != null)
                      DropdownButton<int>(
                        value: widget.pageSize,
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
                            widget.onPageSizeChanged!(value);
                          }
                        },
                      ),
                    const SizedBox(width: ChargeNetSpacing.sm),
                    CnButton(
                      label: 'Previous',
                      variant: CnButtonVariant.secondary,
                      expand: false,
                      onPressed: canGoPrevious ? widget.onPreviousPage : null,
                    ),
                    const SizedBox(width: ChargeNetSpacing.sm),
                    CnButton(
                      label: 'Next',
                      variant: CnButtonVariant.secondary,
                      expand: false,
                      onPressed: canGoNext ? widget.onNextPage : null,
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
