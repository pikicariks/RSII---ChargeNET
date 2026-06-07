import 'package:flutter/material.dart';

import '../theme/chargenet_colors.dart';
import '../theme/chargenet_theme.dart';

/// Target platform variant for theme density and shell layout.
enum ChargeNetPlatform {
  mobile,
  desktop,
}

/// Root Material shell shared by mobile and desktop apps.
class ChargeNetApp extends StatelessWidget {
  const ChargeNetApp({
    super.key,
    required this.platform,
    this.home,
  });

  final ChargeNetPlatform platform;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    final theme = switch (platform) {
      ChargeNetPlatform.mobile => ChargeNetTheme.mobile(),
      ChargeNetPlatform.desktop => ChargeNetTheme.desktop(),
    };

    return MaterialApp(
      title: 'ChargeNET',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      home: home ?? ChargeNetShell(platform: platform),
    );
  }
}

/// Minimal placeholder shell until feature screens land in S1+.
class ChargeNetShell extends StatelessWidget {
  const ChargeNetShell({super.key, required this.platform});

  final ChargeNetPlatform platform;

  @override
  Widget build(BuildContext context) {
    final label = switch (platform) {
      ChargeNetPlatform.mobile => 'Mobile',
      ChargeNetPlatform.desktop => 'Desktop',
    };

    return Scaffold(
      backgroundColor: ChargeNetColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'ChargeNET',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
