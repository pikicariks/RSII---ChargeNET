import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';
import '../widgets/cn_button.dart';
import '../widgets/cn_card.dart';
import '../widgets/cn_error_view.dart';
import '../widgets/cn_loading.dart';
import '../widgets/cn_status_badge.dart';
import '../widgets/cn_text_field.dart';

/// Dev-only gallery of shared widgets (S2 acceptance screen).
class WidgetGalleryScreen extends StatelessWidget {
  const WidgetGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Widget gallery'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ChargeNetSpacing.md),
        children: [
          Text('Buttons', style: ChargeNetTextStyles.title()),
          const SizedBox(height: ChargeNetSpacing.sm),
          const CnButton(label: 'Primary', onPressed: _noop),
          const SizedBox(height: ChargeNetSpacing.sm),
          const CnButton(
            label: 'Secondary',
            variant: CnButtonVariant.secondary,
            onPressed: _noop,
            expand: false,
          ),
          const SizedBox(height: ChargeNetSpacing.sm),
          const CnButton(
            label: 'Destructive',
            variant: CnButtonVariant.destructive,
            onPressed: _noop,
            expand: false,
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          Text('Card', style: ChargeNetTextStyles.title()),
          const SizedBox(height: ChargeNetSpacing.sm),
          CnCard(
            gradientBorder: true,
            onTap: _noop,
            child: Text('Station card with hover border', style: ChargeNetTextStyles.body()),
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          Text('Text field', style: ChargeNetTextStyles.title()),
          const SizedBox(height: ChargeNetSpacing.sm),
          const CnTextField(
            label: 'Search stations',
            hint: 'Find a charger…',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          Text('Status badges', style: ChargeNetTextStyles.title()),
          const SizedBox(height: ChargeNetSpacing.sm),
          const Wrap(
            spacing: ChargeNetSpacing.sm,
            runSpacing: ChargeNetSpacing.sm,
            children: [
              CnStatusBadge(status: CnStationStatus.active),
              CnStatusBadge(status: CnStationStatus.inactive),
              CnStatusBadge(status: CnStationStatus.maintenance),
              CnStatusBadge(status: CnStationStatus.charging),
            ],
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          Text('Loading & error', style: ChargeNetTextStyles.title()),
          const SizedBox(height: ChargeNetSpacing.sm),
          const SizedBox(height: 80, child: CnLoading(message: 'Loading stations…')),
          const SizedBox(height: ChargeNetSpacing.sm),
          const CnErrorView(
            message: 'Failed to load data.',
            onRetry: _noop,
            expand: false,
          ),
        ],
      ),
    );
  }
}

void _noop() {}
