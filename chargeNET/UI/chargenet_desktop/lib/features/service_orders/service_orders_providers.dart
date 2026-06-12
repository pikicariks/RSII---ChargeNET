import 'package:chargenet_desktop/features/service_orders/mock_service_order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockServiceOrdersProvider =
    NotifierProvider<MockServiceOrdersNotifier, List<MockServiceOrder>>(
  MockServiceOrdersNotifier.new,
);

class MockServiceOrdersNotifier extends Notifier<List<MockServiceOrder>> {
  var _nextId = 1003;

  @override
  List<MockServiceOrder> build() {
    return [
      MockServiceOrder(
        id: 1001,
        stationName: 'ChargeNET Baščaršija',
        issue: 'Connector A intermittent power',
        technician: 'Amir Hadžić',
        scheduledDate: DateTime.now().add(const Duration(days: 2)),
        status: 'Scheduled',
      ),
      MockServiceOrder(
        id: 1002,
        stationName: 'ChargeNET Ilidža',
        issue: 'Display panel offline',
        technician: 'Selma Kovač',
        scheduledDate: DateTime.now().add(const Duration(days: 5)),
        status: 'In progress',
      ),
    ];
  }

  void addOrder({
    required String stationName,
    int? faultReportId,
    required String issue,
    required String technician,
    required DateTime scheduledDate,
    String status = 'Scheduled',
  }) {
    state = [
      MockServiceOrder(
        id: _nextId++,
        stationName: stationName,
        faultReportId: faultReportId,
        issue: issue,
        technician: technician,
        scheduledDate: scheduledDate,
        status: status,
      ),
      ...state,
    ];
  }
}
