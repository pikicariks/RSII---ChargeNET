import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:chargenet_mobile/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ChargeNET driver mobile app root.
class MobileApp extends ConsumerWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(mobileRouterProvider);
    return ChargeNetMaterialApp(
      platform: ChargeNetPlatform.mobile,
      routerConfig: router,
    );
  }
}
