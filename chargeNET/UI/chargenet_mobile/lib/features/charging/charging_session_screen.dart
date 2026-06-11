import 'dart:async';

import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final chargingSessionProvider =
    FutureProvider.family<ChargingSession, int>((ref, id) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getSession(id);
});

/// M4 — active charging session with elapsed time and stop action.
class ChargingSessionScreen extends ConsumerStatefulWidget {
  const ChargingSessionScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<ChargingSessionScreen> createState() =>
      _ChargingSessionScreenState();
}

class _ChargingSessionScreenState extends ConsumerState<ChargingSessionScreen> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker(DateTime startTime) {
    _ticker?.cancel();
    _elapsed = DateTime.now().difference(startTime.toLocal());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(startTime.toLocal());
        });
      }
    });
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Future<void> _stopCharging(ChargingSession session) async {
    final controller = TextEditingController(text: '12');
    final kwh = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChargeNetColors.surface,
        title: const Text('Stop charging'),
        content: CnTextField(
          controller: controller,
          label: 'Energy delivered (kWh)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (kwh == null || kwh <= 0 || !mounted) return;

    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.completeSession(session.id, energyKwh: kwh);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Charging session completed')),
      );
      context.go('/');
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(chargingSessionProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging'),
        automaticallyImplyLeading: false,
      ),
      body: sessionAsync.when(
        loading: () => const CnLoading(message: 'Loading session…'),
        error: (e, _) => CnErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(chargingSessionProvider(widget.sessionId)),
        ),
        data: (session) {
          if (session.isActive && (_ticker == null || !_ticker!.isActive)) {
            _startTicker(session.startTime);
          }

          return Padding(
            padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CnCard(
                  gradientBorder: true,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 48,
                        color: ChargeNetColors.primary,
                      ),
                      const SizedBox(height: ChargeNetSpacing.md),
                      Text(
                        session.chargingStationName,
                        style: ChargeNetTextStyles.title(),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        session.connectorLabel,
                        style: ChargeNetTextStyles.bodySm(),
                      ),
                      const SizedBox(height: ChargeNetSpacing.lg),
                      Text(
                        session.isActive ? _formatElapsed(_elapsed) : 'Completed',
                        style: ChargeNetTextStyles.heading(
                          color: ChargeNetColors.primary,
                        ),
                      ),
                      Text('Elapsed', style: ChargeNetTextStyles.caption()),
                      if (session.energyConsumedKwh != null) ...[
                        const SizedBox(height: ChargeNetSpacing.md),
                        Text(
                          '${session.energyConsumedKwh!.toStringAsFixed(1)} kWh',
                          style: ChargeNetTextStyles.title(),
                        ),
                      ],
                      if (session.cost != null) ...[
                        const SizedBox(height: ChargeNetSpacing.xs),
                        Text(
                          '€${session.cost!.toStringAsFixed(2)}',
                          style: ChargeNetTextStyles.bodySm(
                            color: ChargeNetColors.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: ChargeNetSpacing.sm),
                      Text(
                        session.tariffName,
                        style: ChargeNetTextStyles.caption(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (session.isActive)
                  CnButton(
                    label: 'Stop charging',
                    variant: CnButtonVariant.destructive,
                    onPressed: () => _stopCharging(session),
                  )
                else
                  CnButton(
                    label: 'Back to map',
                    onPressed: () => context.go('/'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
