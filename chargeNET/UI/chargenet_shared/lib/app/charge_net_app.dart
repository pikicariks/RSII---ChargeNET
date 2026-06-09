import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/endpoints.dart';
import '../config/app_config.dart';
import '../providers/app_providers.dart';
import '../theme/chargenet_colors.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';
import '../theme/chargenet_theme.dart';
import '../widgets/cn_button.dart' show CnButton, CnButtonVariant;
import '../widgets/cn_loading.dart';
import 'app_routes.dart';
import 'app_router.dart';

/// Target platform variant for theme density and shell layout.
enum ChargeNetPlatform {
  mobile,
  desktop,
}

/// Root Material shell shared by mobile and desktop apps.
class ChargeNetApp extends ConsumerWidget {
  const ChargeNetApp({
    super.key,
    required this.platform,
  });

  final ChargeNetPlatform platform;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider(platform));
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
            router.routerDelegate.navigatorKey.currentContext ?? context,
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
      routerConfig: router,
    );
  }
}

/// Authenticated home shell — placeholder until feature screens land.
class ChargeNetShell extends ConsumerStatefulWidget {
  const ChargeNetShell({super.key, required this.platform});

  final ChargeNetPlatform platform;

  @override
  ConsumerState<ChargeNetShell> createState() => _ChargeNetShellState();
}

class _ChargeNetShellState extends ConsumerState<ChargeNetShell> {
  var _testingApi = false;
  String? _apiTestResult;

  Future<void> _testStationsApi() async {
    setState(() {
      _testingApi = true;
      _apiTestResult = null;
    });

    try {
      final client = await ref.read(apiClientProvider.future);
      final stations = await client.get<List<dynamic>>(
        ApiEndpoints.chargingStations,
      );
      if (!mounted) return;
      setState(() {
        _apiTestResult = 'Loaded ${stations.length} station(s) from API.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _apiTestResult = e.toString());
    } finally {
      if (mounted) setState(() => _testingApi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final session = auth.session;
    final label = switch (widget.platform) {
      ChargeNetPlatform.mobile => 'Mobile',
      ChargeNetPlatform.desktop => 'Desktop',
    };

    if (auth.isRestoring) {
      return const Scaffold(
        body: CnLoading(message: 'Restoring session…'),
      );
    }

    return Scaffold(
      backgroundColor: ChargeNetColors.background,
      appBar: AppBar(
        title: Text('$label — ChargeNET'),
        actions: [
          if (AppConfig.showWidgetGallery)
            IconButton(
              tooltip: 'Widget gallery',
              onPressed: () => context.push(AppRoutes.widgetGallery),
              icon: const Icon(Icons.palette_outlined),
            ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(
            widget.platform == ChargeNetPlatform.mobile
                ? ChargeNetSpacing.mobileHorizontal
                : ChargeNetSpacing.desktopHorizontal,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: ChargeNetSpacing.md),
                Text(
                  'Welcome, ${session?.firstName ?? 'User'}',
                  style: ChargeNetTextStyles.heading(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ChargeNetSpacing.sm),
                Text(
                  '${session?.email ?? ''} · ${session?.role.apiName ?? ''}',
                  style: ChargeNetTextStyles.bodySm(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ChargeNetSpacing.lg),
                CnButton(
                  label: 'Test API — load stations',
                  onPressed: _testingApi ? null : _testStationsApi,
                  isLoading: _testingApi,
                  variant: CnButtonVariant.secondary,
                ),
                if (_apiTestResult != null) ...[
                  const SizedBox(height: ChargeNetSpacing.md),
                  Text(
                    _apiTestResult!,
                    textAlign: TextAlign.center,
                    style: ChargeNetTextStyles.bodySm(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
