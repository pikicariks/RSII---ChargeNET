import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Top header bar — page title + notifications bell stub (D-freestyle-notif).
class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: ChargeNetSpacing.lg),
      decoration: const BoxDecoration(
        color: ChargeNetColors.background,
        border: Border(
          bottom: BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
      ),
      child: Row(
        children: [
          Text(title, style: ChargeNetTextStyles.title()),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications panel — D-freestyle-notif'),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
                color: ChargeNetColors.textSecondary,
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ChargeNetColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
