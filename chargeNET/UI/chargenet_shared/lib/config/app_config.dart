import 'package:flutter/foundation.dart';

/// API base URL resolution per platform / build flags.
///
/// Override at build time: `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000`
abstract final class AppConfig {
  static const _defineKey = 'API_BASE_URL';

  /// Resolved backend URL for the current target.
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment(_defineKey);
    if (fromDefine.isNotEmpty) return fromDefine;

    if (kIsWeb) return 'http://localhost:5000';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:5000',
      TargetPlatform.iOS => 'http://localhost:5000',
      _ => 'http://localhost:5000', // Windows / macOS / Linux desktop
    };
  }

  /// Dev-only widget gallery route flag.
  static const showWidgetGallery = bool.fromEnvironment(
    'SHOW_WIDGET_GALLERY',
    defaultValue: kDebugMode,
  );
}
