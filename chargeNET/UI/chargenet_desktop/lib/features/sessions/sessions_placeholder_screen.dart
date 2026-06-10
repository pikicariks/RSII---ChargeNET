import 'package:chargenet_desktop/features/feature_placeholder_screen.dart';
import 'package:flutter/material.dart';

class SessionsPlaceholderScreen extends StatelessWidget {
  const SessionsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Charging Sessions',
      step: 'D3',
      icon: Icons.bolt_outlined,
    );
  }
}
