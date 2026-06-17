import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Mock service order form (D-freestyle-so) — shared by D6 faults and D8 list.
class ServiceOrderFormDialog extends StatefulWidget {
  const ServiceOrderFormDialog({
    super.key,
    this.stationName,
    this.faultReportId,
    this.issue,
  });

  final String? stationName;
  final int? faultReportId;
  final String? issue;

  static Future<ServiceOrderFormResult?> show(
    BuildContext context, {
    String? stationName,
    int? faultReportId,
    String? issue,
  }) {
    return showDialog<ServiceOrderFormResult>(
      context: context,
      builder: (_) => ServiceOrderFormDialog(
        stationName: stationName,
        faultReportId: faultReportId,
        issue: issue,
      ),
    );
  }

  @override
  State<ServiceOrderFormDialog> createState() => _ServiceOrderFormDialogState();
}

class ServiceOrderFormResult {
  ServiceOrderFormResult({
    required this.stationName,
    this.faultReportId,
    required this.issue,
    required this.technician,
    required this.scheduledDate,
  });

  final String stationName;
  final int? faultReportId;
  final String issue;
  final String technician;
  final DateTime scheduledDate;
}

class _ServiceOrderFormDialogState extends State<ServiceOrderFormDialog> {
  late final TextEditingController _station;
  late final TextEditingController _issue;
  late final TextEditingController _technician;
  DateTime _scheduled = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _station = TextEditingController(text: widget.stationName ?? '');
    _issue = TextEditingController(text: widget.issue ?? '');
    _technician = TextEditingController(text: 'Technician');
  }

  @override
  void dispose() {
    _station.dispose();
    _issue.dispose();
    _technician.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduled,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _scheduled = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ChargeNetColors.surface,
      title: const Text('Create service order'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CnTextField(
                controller: _station,
                hint: 'Station name',
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              CnTextField(
                controller: _issue,
                hint: 'Issue description',
                maxLines: 3,
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              CnTextField(
                controller: _technician,
                hint: 'Technician',
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Scheduled', style: ChargeNetTextStyles.bodySm()),
                subtitle: Text(formatChargeNetDate(_scheduled)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: _pickDate,
                ),
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
          label: 'Create',
          expand: false,
          onPressed: () {
            if (_station.text.trim().isEmpty || _issue.text.trim().isEmpty) {
              return;
            }
            Navigator.pop(
              context,
              ServiceOrderFormResult(
                stationName: _station.text.trim(),
                faultReportId: widget.faultReportId,
                issue: _issue.text.trim(),
                technician: _technician.text.trim(),
                scheduledDate: _scheduled,
              ),
            );
          },
        ),
      ],
    );
  }
}
