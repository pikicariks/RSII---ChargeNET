import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Bottom nav — Map | History | Profile (matches Figma BottomNav.tsx).
class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'Map'),
    (
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ChargeNetColors.surface,
        border: Border(
          top: BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: ChargeNetSpacing.sm,
            horizontal: ChargeNetSpacing.md,
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;
              final color = selected
                  ? ChargeNetColors.primary
                  : ChargeNetColors.textMuted;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: selected ? ChargeNetColors.primaryMuted : Colors.transparent,
                    borderRadius: BorderRadius.circular(ChargeNetRadii.md),
                  ),
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(ChargeNetRadii.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: ChargeNetSpacing.xs,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            color: color,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: ChargeNetTextStyles.caption(color: color)
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
