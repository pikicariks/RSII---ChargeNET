import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../theme/chargenet_theme.dart';

/// Target platform variant for theme density and auth layout.
enum ChargeNetPlatform {
  mobile,
  desktop,
}

/// Root [MaterialApp.router] wrapper — apps supply their own [GoRouter].
class ChargeNetMaterialApp extends ConsumerWidget {
  const ChargeNetMaterialApp({
    super.key,
    required this.platform,
    required this.routerConfig,
  });

  final ChargeNetPlatform platform;
  final GoRouter routerConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = switch (platform) {
      ChargeNetPlatform.mobile => ChargeNetTheme.mobile(),
      ChargeNetPlatform.desktop => ChargeNetTheme.desktop(),
    };

    ref.listen(authProvider, (previous, next) {
      if (next.error != null &&
          next.error != previous?.error &&
          !next.isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final messenger = ScaffoldMessenger.maybeOf(
            routerConfig.routerDelegate.navigatorKey.currentContext ??
                context,
          );
          messenger?.showSnackBar(SnackBar(content: Text(next.error!)));
        });
      }
    });

    return MaterialApp.router(
      title: 'ChargeNET',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: routerConfig,
    );
  }
}

/// @deprecated Use [ChargeNetMaterialApp] with an app-specific router.
typedef ChargeNetApp = ChargeNetMaterialApp;
