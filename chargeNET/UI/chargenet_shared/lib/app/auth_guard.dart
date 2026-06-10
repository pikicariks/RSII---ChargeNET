import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_state.dart';
import '../providers/app_providers.dart';
import 'app_routes.dart';
import 'charge_net_app.dart';

/// Shared auth + role redirect logic for app-specific [GoRouter] configs.
String? authRedirect({
  required Ref ref,
  required ChargeNetPlatform platform,
  required String location,
  required String authenticatedHome,
}) {
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

  if (isAuthRoute || isRoleDenied) return authenticatedHome;
  return null;
}

/// Listens to [authProvider] and bumps [refresh] so [GoRouter] re-runs redirect.
void bindAuthRefreshListenable({
  required Ref ref,
  required ValueNotifier<int> refresh,
}) {
  ref.listen<AuthState>(authProvider, (_, __) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);
}
