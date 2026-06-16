import 'package:chargenet_desktop/widgets/notifications_panel.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

/// Top header bar — page title + notifications panel (D-freestyle-notif).
class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: ChargeNetSpacing.lg),
      decoration: const BoxDecoration(
        color: ChargeNetColors.background,
        border: Border(
          bottom: BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: ChargeNetTextStyles.title()),
          const Spacer(),
          const NotificationsPanel(),
        ],
      ),
    );
  }
}
