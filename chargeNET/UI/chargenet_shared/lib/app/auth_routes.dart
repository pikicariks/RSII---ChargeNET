import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/role_denied_screen.dart';
import '../screens/widget_gallery_screen.dart';
import 'app_routes.dart';
import 'charge_net_app.dart';

/// Login, register, role-denied, and optional dev gallery routes.
List<RouteBase> buildAuthRoutes({required ChargeNetPlatform platform}) {
  return [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginScreen(platform: platform),
    ),
    if (platform == ChargeNetPlatform.mobile)
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
    if (platform == ChargeNetPlatform.mobile)
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
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
  ];
}
