import 'package:chargenet_desktop/features/feature_placeholder_screen.dart';
import 'package:flutter/material.dart';

class ReportsPlaceholderScreen extends StatelessWidget {
  const ReportsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Reports & Analytics',
      step: 'D7',
      icon: Icons.bar_chart_outlined,
    );
  }
}
