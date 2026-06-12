import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

enum ReportDatePreset { days7, days30, days90, custom }

class ReportDateRange {
  const ReportDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }
}

/// D-freestyle-dates — preset chips + optional custom range.
class DateRangeDialog extends StatefulWidget {
  const DateRangeDialog({super.key, required this.initial});

  final ReportDateRange initial;

  static Future<ReportDateRange?> show(
    BuildContext context, {
    required ReportDateRange initial,
  }) {
    return showDialog<ReportDateRange>(
      context: context,
      builder: (_) => DateRangeDialog(initial: initial),
    );
  }

  @override
  State<DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<DateRangeDialog> {
  late ReportDatePreset _preset;
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initial.start;
    _end = widget.initial.end;
    _preset = ReportDatePreset.days30;
  }

  void _applyPreset(ReportDatePreset preset) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final days = switch (preset) {
      ReportDatePreset.days7 => 7,
      ReportDatePreset.days30 => 30,
      ReportDatePreset.days90 => 90,
      ReportDatePreset.custom => 0,
    };
    setState(() {
      _preset = preset;
      if (preset != ReportDatePreset.custom) {
        _end = end;
        _start = end.subtract(Duration(days: days - 1));
      }
    });
  }

  Future<void> _pickCustom() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (range != null) {
      setState(() {
        _preset = ReportDatePreset.custom;
        _start = range.start;
        _end = range.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ChargeNetColors.surface,
      title: const Text('Date range'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: ChargeNetSpacing.sm,
              runSpacing: ChargeNetSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('7 days'),
                  selected: _preset == ReportDatePreset.days7,
                  onSelected: (_) => _applyPreset(ReportDatePreset.days7),
                ),
                ChoiceChip(
                  label: const Text('30 days'),
                  selected: _preset == ReportDatePreset.days30,
                  onSelected: (_) => _applyPreset(ReportDatePreset.days30),
                ),
                ChoiceChip(
                  label: const Text('90 days'),
                  selected: _preset == ReportDatePreset.days90,
                  onSelected: (_) => _applyPreset(ReportDatePreset.days90),
                ),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: _preset == ReportDatePreset.custom,
                  onSelected: (_) => _pickCustom(),
                ),
              ],
            ),
            const SizedBox(height: ChargeNetSpacing.md),
            Text(
              '${formatChargeNetDate(_start)} – ${formatChargeNetDate(_end)}',
              style: ChargeNetTextStyles.bodySm(),
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
          label: 'Apply',
          expand: false,
          onPressed: () => Navigator.pop(
            context,
            ReportDateRange(start: _start, end: _end),
          ),
        ),
      ],
    );
  }
}
