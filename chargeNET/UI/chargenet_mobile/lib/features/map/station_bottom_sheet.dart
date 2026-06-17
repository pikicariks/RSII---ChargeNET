import 'package:chargenet_mobile/features/map/map_providers.dart';
import 'package:chargenet_mobile/features/map/station_card.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StationBottomSheet extends ConsumerWidget {
  const StationBottomSheet({
    super.key,
    required this.onStationTap,
  });

  final ValueChanged<RecommendedStation> onStationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(filteredRecommendationsProvider);
    final recommendationCount = recommendations.maybeWhen(
      data: (items) => items.length,
      orElse: () => null,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ChargeNetColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ChargeNetRadii.xl),
        ),
        border: Border(
          top: BorderSide(color: ChargeNetColors.surfaceElevated),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: ChargeNetSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ChargeNetColors.surfaceElevated,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ChargeNetSpacing.mobileHorizontal,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recommended near you',
                    style: ChargeNetTextStyles.title(),
                  ),
                ),
                if (recommendationCount != null)
                  Text(
                    '$recommendationCount',
                    style: ChargeNetTextStyles.caption(
                      color: ChargeNetColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: ChargeNetSpacing.sm),
          Expanded(
            child: recommendations.when(
              loading: () => const CnLoading(message: 'Finding stations…'),
              error: (e, _) => CnErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(recommendationsProvider),
                expand: false,
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        ChargeNetSpacing.mobileHorizontal,
                      ),
                      child: Text(
                        'No stations found. Create stations in the admin app (D2).',
                        textAlign: TextAlign.center,
                        style: ChargeNetTextStyles.bodySm(),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    ChargeNetSpacing.mobileHorizontal,
                    0,
                    ChargeNetSpacing.mobileHorizontal,
                    ChargeNetSpacing.lg,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: ChargeNetSpacing.sm),
                  itemBuilder: (context, index) {
                    final station = items[index];
                    return StationCard(
                      station: station,
                      onTap: () => onStationTap(station),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
