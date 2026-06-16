import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';

class ConnectorTile extends StatelessWidget {
  const ConnectorTile({super.key, required this.connector});

  final Connector connector;

  @override
  Widget build(BuildContext context) {
    final label = connector.label?.isNotEmpty == true
        ? connector.label!
        : connector.connectorTypeName;

    return Padding(
      padding: const EdgeInsets.only(bottom: ChargeNetSpacing.sm),
      child: CnCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ChargeNetColors.primaryMuted,
                borderRadius: BorderRadius.circular(ChargeNetRadii.md),
              ),
              child: const Icon(
                Icons.power_rounded,
                color: ChargeNetColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: ChargeNetSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: ChargeNetTextStyles.label()),
                  const SizedBox(height: 2),
                  Text(
                    '${connector.powerKw.toStringAsFixed(0)} kW · ${connector.connectorTypeName}',
                    style: ChargeNetTextStyles.caption(),
                  ),
                ],
              ),
            ),
            CnStatusBadge(
              status: connector.isAvailable
                  ? CnStationStatus.active
                  : CnStationStatus.inactive,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}
