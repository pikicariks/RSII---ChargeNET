import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:chargenet_desktop/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ChargeNET admin desktop app root.
class DesktopApp extends ConsumerWidget {
  const DesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);
    return ChargeNetMaterialApp(
      platform: ChargeNetPlatform.desktop,
      routerConfig: router,
    );
  }
}
