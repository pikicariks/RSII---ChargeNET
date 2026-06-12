import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../config/app_config.dart';
import '../models/notification.dart';

/// Real-time notification hub client (S5).
class SignalRService {
  HubConnection? _connection;
  final _events = StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get events => _events.stream;

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  Future<void> connect({required String accessToken}) async {
    if (isConnected) return;

    await disconnect();

    final connection = HubConnectionBuilder()
        .withUrl(
          AppConfig.notificationHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
          ),
        )
        .withAutomaticReconnect()
        .build();

    connection.on('ReceiveNotification', (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final raw = arguments.first;
      if (raw is Map<String, dynamic>) {
        _events.add(AppNotification.fromJson(raw));
      } else if (raw is Map) {
        _events.add(AppNotification.fromJson(Map<String, dynamic>.from(raw)));
      }
    });

    await connection.start();
    _connection = connection;
  }

  Future<void> disconnect() async {
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      try {
        await connection.stop();
      } catch (_) {
        // Best-effort stop.
      }
    }
  }

  void dispose() {
    unawaited(disconnect());
    _events.close();
  }
}
