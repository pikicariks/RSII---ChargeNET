import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Map tab placeholder — replaced in M1 with flutter_map + recommendations.
class MapPlaceholderScreen extends StatelessWidget {
  const MapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            ChargeNetColors.background,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: ChargeNetSpacing.md),
            Text('Map', style: ChargeNetTextStyles.title()),
            const SizedBox(height: ChargeNetSpacing.sm),
            Text(
              'Station map & recommendations — M1',
              style: ChargeNetTextStyles.bodySm(),
            ),
          ],
        ),
      ),
    );
  }
}
