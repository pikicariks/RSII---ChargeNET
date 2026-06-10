import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final api = await ref.watch(chargeNetApiProvider.future);

  final results = await Future.wait([
    api.getStations(),
    api.getSessions(),
    api.getFaultReports(),
    api.getTransactions(),
  ]);

  final stations = results[0] as List<ChargingStation>;
  final sessions = results[1] as List<ChargingSession>;
  final faults = results[2] as List<FaultReport>;
  final transactions = results[3] as List<Transaction>;

  final now = DateTime.now().toUtc();
  final todayStart = DateTime.utc(now.year, now.month, now.day);
  final monthStart = DateTime.utc(now.year, now.month, 1);

  final activeSessions = sessions.where((s) => s.isActive).length;
  final openFaults = faults.where((f) => !f.isResolved).length;

  double revenueFor(DateTime since) => transactions
      .where((t) =>
          t.createdAt.isAfter(since) &&
          t.status.toLowerCase() == 'completed' &&
          t.amount > 0)
      .fold(0, (sum, t) => sum + t.amount);

  final recent = [...sessions]
    ..sort((a, b) => b.startTime.compareTo(a.startTime));

  return DashboardData(
    totalStations: stations.length,
    activeSessions: activeSessions,
    revenueToday: revenueFor(todayStart),
    revenueMonth: revenueFor(monthStart),
    openFaults: openFaults,
    recentSessions: recent.take(10).toList(),
  );
});

class DashboardData {
  const DashboardData({
    required this.totalStations,
    required this.activeSessions,
    required this.revenueToday,
    required this.revenueMonth,
    required this.openFaults,
    required this.recentSessions,
  });

  final int totalStations;
  final int activeSessions;
  final double revenueToday;
  final double revenueMonth;
  final int openFaults;
  final List<ChargingSession> recentSessions;
}
