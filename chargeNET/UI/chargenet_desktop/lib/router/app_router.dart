import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:chargenet_desktop/features/dashboard/dashboard_screen.dart';
import 'package:chargenet_desktop/features/faults/faults_placeholder_screen.dart';
import 'package:chargenet_desktop/features/reports/reports_placeholder_screen.dart';
import 'package:chargenet_desktop/features/service_orders/service_orders_placeholder_screen.dart';
import 'package:chargenet_desktop/features/sessions/sessions_placeholder_screen.dart';
import 'package:chargenet_desktop/features/settings/settings_screen.dart';
import 'package:chargenet_desktop/features/stations/stations_screen.dart';
import 'package:chargenet_desktop/features/tariffs/tariffs_placeholder_screen.dart';
import 'package:chargenet_desktop/features/users/users_placeholder_screen.dart';
import 'package:chargenet_desktop/shell/admin_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  bindAuthRefreshListenable(ref: ref, refresh: refresh);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      ref: ref,
      platform: ChargeNetPlatform.desktop,
      location: state.matchedLocation,
      authenticatedHome: AdminRoutes.dashboard,
    ),
    routes: [
      ...buildAuthRoutes(platform: ChargeNetPlatform.desktop),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AdminRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AdminRoutes.stations,
            builder: (context, state) => const StationsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => StationDetailScreen(
                  stationId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.sessions,
            builder: (context, state) => const SessionsPlaceholderScreen(),
          ),
          GoRoute(
            path: AdminRoutes.reports,
            builder: (context, state) => const ReportsPlaceholderScreen(),
          ),
          GoRoute(
            path: AdminRoutes.tariffs,
            builder: (context, state) => const TariffsPlaceholderScreen(),
          ),
          GoRoute(
            path: AdminRoutes.faults,
            builder: (context, state) => const FaultsPlaceholderScreen(),
          ),
          GoRoute(
            path: AdminRoutes.users,
            builder: (context, state) => const UsersPlaceholderScreen(),
          ),
          GoRoute(
            path: AdminRoutes.serviceOrders,
            builder: (context, state) => const ServiceOrdersPlaceholderScreen(),
          ),
          GoRoute(
            path: AdminRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
