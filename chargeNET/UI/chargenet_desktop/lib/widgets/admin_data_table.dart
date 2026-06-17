import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Full-width admin table with equal column widths.
class AdminDataTable extends StatelessWidget {
  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.headingRowColor,
    this.horizontalMargin = ChargeNetSpacing.md,
    this.columnSpacing = ChargeNetSpacing.md,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final WidgetStateProperty<Color?>? headingRowColor;
  final double horizontalMargin;
  final double columnSpacing;

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) {
      return const SizedBox.shrink();
    }

    final headerColor = headingRowColor?.resolve({}) ??
        ChargeNetColors.surfaceElevated.withValues(alpha: 0.35);
    final columnWidths = <int, TableColumnWidth>{
      for (var i = 0; i < columns.length; i++) i: const FlexColumnWidth(1),
    };
    final cellPadding = EdgeInsets.symmetric(
      horizontal: horizontalMargin / 2,
      vertical: ChargeNetSpacing.sm + 2,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
          child: Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder(
              horizontalInside: BorderSide(
                color: ChargeNetColors.surfaceElevated.withValues(alpha: 0.6),
              ),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(color: headerColor),
                children: [
                  for (final column in columns)
                    Padding(
                      padding: cellPadding,
                      child: DefaultTextStyle(
                        style: ChargeNetTextStyles.label(),
                        child: column.label,
                      ),
                    ),
                ],
              ),
              for (final row in rows)
                TableRow(
                  children: [
                    for (final cell in row.cells)
                      Padding(
                        padding: cellPadding,
                        child: ClipRect(
                          child: cell.child,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
