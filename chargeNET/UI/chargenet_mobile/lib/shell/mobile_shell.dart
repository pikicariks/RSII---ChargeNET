import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bottom_nav.dart';

/// Driver app scaffold — full-bleed content + bottom navigation (M0).
class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChargeNetColors.background,
      body: navigationShell,
      bottomNavigationBar: MobileBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
      ),
    );
  }
}
