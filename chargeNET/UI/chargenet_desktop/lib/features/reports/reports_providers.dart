import 'package:chargenet_desktop/widgets/date_range_dialog.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsDateRangeProvider = StateProvider<ReportDateRange>((ref) {
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  return ReportDateRange(
    start: end.subtract(const Duration(days: 29)),
    end: end,
  );
});

final reportsDataProvider = FutureProvider<ReportsData>((ref) async {
  final range = ref.watch(reportsDateRangeProvider);
  final api = await ref.watch(chargeNetApiProvider.future);

  final transactions = await api.getTransactions();
  final sessions = await api.getSessions();
  final invoices = await api.getInvoices();

  final filteredTx =
      transactions.where((t) => range.contains(t.createdAt)).toList();
  final filteredSessions = sessions
      .where((s) => range.contains(s.startTime) && !s.isActive)
      .toList();

  return ReportsData(
    transactions: filteredTx,
    sessions: filteredSessions,
    invoices: invoices.where((i) => range.contains(i.invoiceDate)).toList(),
    range: range,
  );
});

class ReportsData {
  ReportsData({
    required this.transactions,
    required this.sessions,
    required this.invoices,
    required this.range,
  });

  final List<Transaction> transactions;
  final List<ChargingSession> sessions;
  final List<Invoice> invoices;
  final ReportDateRange range;

  double get totalRevenue => transactions
      .where((t) => t.amount > 0)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalEnergyKwh => sessions.fold(
        0,
        (sum, s) => sum + (s.energyConsumedKwh ?? 0),
      );

  Map<String, double> revenueByDay() {
    final map = <String, double>{};
    for (final t in transactions.where((t) => t.amount > 0)) {
      final key = formatChargeNetDate(t.createdAt);
      map[key] = (map[key] ?? 0) + t.amount;
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  Map<String, int> sessionsByStation() {
    final map = <String, int>{};
    for (final s in sessions) {
      map[s.chargingStationName] = (map[s.chargingStationName] ?? 0) + 1;
    }
    return map;
  }
}
