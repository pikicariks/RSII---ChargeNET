import 'package:chargenet_desktop/features/feature_placeholder_screen.dart';
import 'package:flutter/material.dart';

class TariffsPlaceholderScreen extends StatelessWidget {
  const TariffsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Tariffs',
      step: 'D5',
      icon: Icons.payments_outlined,
    );
  }
}
