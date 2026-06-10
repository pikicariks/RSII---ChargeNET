import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:chargenet_mobile/features/history/history_placeholder_screen.dart';
import 'package:chargenet_mobile/features/map/map_screen.dart';
import 'package:chargenet_mobile/features/reservation/reservation_placeholder_screen.dart';
import 'package:chargenet_mobile/features/station/station_detail_screen.dart';
import 'package:chargenet_mobile/features/profile/profile_placeholder_screen.dart';
import 'package:chargenet_mobile/shell/mobile_shell.dart';
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
            builder: (context, state) => ReservationPlaceholderScreen(
              stationId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
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
                builder: (context, state) => const HistoryPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MobileRoutes.profile,
                builder: (context, state) => const ProfilePlaceholderScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
