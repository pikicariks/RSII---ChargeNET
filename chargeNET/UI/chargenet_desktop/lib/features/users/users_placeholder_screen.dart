import 'package:chargenet_desktop/features/feature_placeholder_screen.dart';
import 'package:flutter/material.dart';

class UsersPlaceholderScreen extends StatelessWidget {
  const UsersPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'User Management',
      step: 'D4',
      icon: Icons.group_outlined,
    );
  }
}
