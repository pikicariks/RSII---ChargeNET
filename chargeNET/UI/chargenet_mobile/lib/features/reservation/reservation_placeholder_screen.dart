import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// M3 reservation flow placeholder — reached from station detail Reserve CTA.
class ReservationPlaceholderScreen extends StatelessWidget {
  const ReservationPlaceholderScreen({super.key, required this.stationId});

  final int stationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Reserve'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
        child: CnCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reservation flow', style: ChargeNetTextStyles.title()),
              const SizedBox(height: ChargeNetSpacing.sm),
              Text(
                'Station #$stationId — date/time picker, connector selection, '
                'and confirm/cancel will be implemented in M3.',
                style: ChargeNetTextStyles.bodySm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
