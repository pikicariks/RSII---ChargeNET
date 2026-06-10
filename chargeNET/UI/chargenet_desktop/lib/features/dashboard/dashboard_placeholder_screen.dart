import 'package:chargenet_desktop/features/feature_placeholder_screen.dart';
import 'package:flutter/material.dart';

class DashboardPlaceholderScreen extends StatelessWidget {
  const DashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Dashboard',
      step: 'D1',
      icon: Icons.dashboard_outlined,
    );
  }
}
