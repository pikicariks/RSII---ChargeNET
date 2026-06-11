import '../api/json_utils.dart';

class Reservation {
  const Reservation({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.chargingStationId,
    required this.chargingStationName,
    this.connectorId,
    this.connectorLabel,
    required this.reservationStart,
    required this.reservationEnd,
    required this.statusId,
    required this.statusName,
  });

  final int id;
  final int userId;
  final String userEmail;
  final int chargingStationId;
  final String chargingStationName;
  final int? connectorId;
  final String? connectorLabel;
  final DateTime reservationStart;
  final DateTime reservationEnd;
  final int statusId;
  final String statusName;

  bool get isPending => statusName.toLowerCase() == 'pending';
  bool get isConfirmed => statusName.toLowerCase() == 'confirmed';
  bool get isCancelled => statusName.toLowerCase() == 'cancelled';

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userEmail: json['userEmail'] as String? ?? '',
      chargingStationId: (json['chargingStationId'] as num?)?.toInt() ?? 0,
      chargingStationName: json['chargingStationName'] as String? ?? '',
      connectorId: (json['connectorId'] as num?)?.toInt(),
      connectorLabel: json['connectorLabel'] as String?,
      reservationStart: DateTime.parse(json['reservationStart'] as String),
      reservationEnd: DateTime.parse(json['reservationEnd'] as String),
      statusId: (json['statusId'] as num?)?.toInt() ?? 0,
      statusName: json['statusName'] as String? ?? '',
    );
  }

  static List<Reservation> listFromJson(dynamic json) =>
      parseJsonList(json, Reservation.fromJson);
}
