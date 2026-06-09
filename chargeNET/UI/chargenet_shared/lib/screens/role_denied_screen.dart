import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/charge_net_app.dart';
import '../providers/app_providers.dart';
import '../theme/chargenet_colors.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';
import '../widgets/cn_button.dart';
import '../widgets/cn_card.dart';

class RoleDeniedScreen extends ConsumerWidget {
  const RoleDeniedScreen({super.key, required this.platform});

  final ChargeNetPlatform platform;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    final message = platform == ChargeNetPlatform.desktop
        ? 'Admin access only. Driver accounts cannot use the desktop console.'
        : 'This app is for drivers. Please use the correct app for your role.';

    return Scaffold(
      backgroundColor: ChargeNetColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ChargeNetSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: CnCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: ChargeNetColors.warning,
                    size: 48,
                  ),
                  const SizedBox(height: ChargeNetSpacing.md),
                  Text(
                    'Access denied',
                    style: ChargeNetTextStyles.title(),
                  ),
                  const SizedBox(height: ChargeNetSpacing.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: ChargeNetTextStyles.bodySm(),
                  ),
                  if (session != null) ...[
                    const SizedBox(height: ChargeNetSpacing.sm),
                    Text(
                      'Signed in as ${session.email} (${session.role.apiName})',
                      textAlign: TextAlign.center,
                      style: ChargeNetTextStyles.caption(),
                    ),
                  ],
                  const SizedBox(height: ChargeNetSpacing.lg),
                  CnButton(
                    label: 'Sign out',
                    variant: CnButtonVariant.secondary,
                    onPressed: () =>
                        ref.read(authProvider.notifier).logout(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
