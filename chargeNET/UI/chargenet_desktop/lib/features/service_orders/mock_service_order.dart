/// In-memory mock service orders (D6/D8 — no backend).
class MockServiceOrder {
  MockServiceOrder({
    required this.id,
    required this.stationName,
    this.faultReportId,
    required this.issue,
    required this.technician,
    required this.scheduledDate,
    required this.status,
  });

  final int id;
  final String stationName;
  final int? faultReportId;
  final String issue;
  final String technician;
  final DateTime scheduledDate;
  final String status;
}
