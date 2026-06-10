import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.onTap,
  });

  final RecommendedStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
      child: CnCard(
        onTap: onTap,
        gradientBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(station.name, style: ChargeNetTextStyles.label()),
                ),
                CnStatusBadge(
                  status: station.isActive
                      ? CnStationStatus.active
                      : CnStationStatus.inactive,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: ChargeNetSpacing.xs),
            Text(
              station.address,
              style: ChargeNetTextStyles.bodySm(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: ChargeNetSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: ChargeNetColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${station.distanceKm.toStringAsFixed(1)} km',
                  style: ChargeNetTextStyles.caption(),
                ),
                const SizedBox(width: ChargeNetSpacing.md),
                Text(
                  '${station.connectorCount} connectors',
                  style: ChargeNetTextStyles.caption(),
                ),
                const Spacer(),
                if (station.rating != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: ChargeNetColors.primary,
                      ),
                      Text(
                        station.rating!.toStringAsFixed(1),
                        style: ChargeNetTextStyles.caption(
                          color: ChargeNetColors.primary,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: ChargeNetSpacing.sm),
                Text(
                  '€${station.estimatedPricePerKwh.toStringAsFixed(2)}/kWh',
                  style: ChargeNetTextStyles.caption(
                    color: ChargeNetColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
