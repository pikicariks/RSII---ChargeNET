import 'package:chargenet_desktop/features/feature_placeholder_screen.dart';
import 'package:flutter/material.dart';

class ServiceOrdersPlaceholderScreen extends StatelessWidget {
  const ServiceOrdersPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Service Orders',
      step: 'D8 (mock data)',
      icon: Icons.build_outlined,
    );
  }
}
