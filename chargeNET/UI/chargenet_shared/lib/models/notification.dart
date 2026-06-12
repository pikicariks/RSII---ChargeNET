import '../api/json_utils.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String title;
  final String message;
  final String notificationType;
  final bool isRead;
  final String? relatedEntityType;
  final int? relatedEntityId;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      notificationType: json['notificationType'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      relatedEntityType: json['relatedEntityType'] as String?,
      relatedEntityId: (json['relatedEntityId'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static List<AppNotification> listFromJson(dynamic json) =>
      parseJsonList(json, AppNotification.fromJson);
}
