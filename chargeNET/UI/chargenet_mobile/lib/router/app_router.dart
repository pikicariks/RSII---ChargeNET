import 'package:chargenet_mobile/features/charging/charging_session_screen.dart';
import 'package:chargenet_mobile/features/history/history_screen.dart';
import 'package:chargenet_mobile/features/map/map_screen.dart';
import 'package:chargenet_mobile/features/notifications/notifications_screen.dart';
import 'package:chargenet_mobile/features/profile/help_screen.dart';
import 'package:chargenet_mobile/features/profile/profile_screen.dart';
import 'package:chargenet_mobile/features/profile/settings_screen.dart';
import 'package:chargenet_mobile/features/profile/vehicles_screen.dart';
import 'package:chargenet_mobile/features/reservation/reservation_screen.dart';
import 'package:chargenet_mobile/features/station/station_detail_screen.dart';
import 'package:chargenet_mobile/features/wallet/wallet_screen.dart';
import 'package:chargenet_mobile/shell/mobile_shell.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

final mobileRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  bindAuthRefreshListenable(ref: ref, refresh: refresh);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      ref: ref,
      platform: ChargeNetPlatform.mobile,
      location: state.matchedLocation,
      authenticatedHome: MobileRoutes.map,
    ),
    routes: [
      ...buildAuthRoutes(platform: ChargeNetPlatform.mobile),
      GoRoute(
        path: '/stations/:id',
        builder: (context, state) => StationDetailScreen(
          stationId: int.parse(state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'reserve',
            builder: (context, state) => ReservationScreen(
              stationId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/vehicles',
        builder: (context, state) => const VehiclesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const MobileSettingsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/charging/:id',
        builder: (context, state) => ChargingSessionScreen(
          sessionId: int.parse(state.pathParameters['id']!),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MobileShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MobileRoutes.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MobileRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MobileRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
