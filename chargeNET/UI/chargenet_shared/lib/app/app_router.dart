import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_state.dart';
import '../config/app_config.dart';
import '../providers/app_providers.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/role_denied_screen.dart';
import '../screens/widget_gallery_screen.dart';
import 'app_routes.dart';
import 'charge_net_app.dart';

final appRouterProvider =
    Provider.family<GoRouter, ChargeNetPlatform>((ref, platform) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AuthState>(authProvider, (_, __) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) =>
        _redirect(ref, platform, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(platform: platform),
      ),
      if (platform == ChargeNetPlatform.mobile)
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
      GoRoute(
        path: AppRoutes.roleDenied,
        builder: (context, state) => RoleDeniedScreen(platform: platform),
      ),
      if (AppConfig.showWidgetGallery)
        GoRoute(
          path: AppRoutes.widgetGallery,
          builder: (context, state) => const WidgetGalleryScreen(),
        ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => ChargeNetShell(platform: platform),
      ),
    ],
  );
});

String? _redirect(
  Ref ref,
  ChargeNetPlatform platform,
  String location,
) {
  final auth = ref.read(authProvider);

  if (auth.isRestoring) return null;

  final isAuthRoute =
      location == AppRoutes.login || location == AppRoutes.register;
  final isRoleDenied = location == AppRoutes.roleDenied;
  final isWidgetGallery = location == AppRoutes.widgetGallery;

  if (!auth.isAuthenticated) {
    if (isAuthRoute || isWidgetGallery) return null;
    return AppRoutes.login;
  }

  final role = auth.session!.role;
  final roleBlocked = platform == ChargeNetPlatform.desktop
      ? !role.canAccessDesktop
      : !role.canAccessMobile;

  if (roleBlocked) {
    if (isRoleDenied) return null;
    return AppRoutes.roleDenied;
  }

  if (isAuthRoute || isRoleDenied) return AppRoutes.home;
  return null;
}
