import 'package:chargenet_desktop/features/feature_placeholder_screen.dart';
import 'package:flutter/material.dart';

class StationsPlaceholderScreen extends StatelessWidget {
  const StationsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Stations',
      step: 'D2',
      icon: Icons.ev_station_outlined,
    );
  }
}
