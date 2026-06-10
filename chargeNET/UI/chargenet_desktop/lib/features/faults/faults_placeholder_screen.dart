import 'package:chargenet_desktop/features/feature_placeholder_screen.dart';
import 'package:flutter/material.dart';

class FaultsPlaceholderScreen extends StatelessWidget {
  const FaultsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Fault Reports',
      step: 'D6',
      icon: Icons.warning_amber_outlined,
    );
  }
}
