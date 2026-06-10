import 'package:chargenet_mobile/features/station/connector_tile.dart';
import 'package:chargenet_mobile/features/station/station_providers.dart';
import 'package:chargenet_mobile/utils/maps_launcher.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full station detail — connectors, tariff, Navigate + Reserve (M2).
class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({super.key, required this.stationId});

  final int stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationAsync = ref.watch(stationDetailProvider(stationId));
    final connectorsAsync = ref.watch(stationConnectorsProvider(stationId));
    final tariffsAsync = ref.watch(activeTariffsProvider);

    return Scaffold(
      body: stationAsync.when(
        loading: () => const CnLoading(message: 'Loading station…'),
        error: (e, _) => CnErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(stationDetailProvider(stationId)),
        ),
        data: (station) {
          final hasCoords =
              station.latitude != null && station.longitude != null;
          final availableCount = connectorsAsync.maybeWhen(
            data: (items) => items.where((c) => c.isAvailable).length,
            orElse: () => null,
          );
          final canReserve =
              station.isActive && (availableCount == null || availableCount > 0);

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 180,
                      pinned: true,
                      leading: BackButton(
                        onPressed: () => context.pop(),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: _HeroPlaceholder(station: station),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        ChargeNetSpacing.mobileHorizontal,
                        ChargeNetSpacing.md,
                        ChargeNetSpacing.mobileHorizontal,
                        ChargeNetSpacing.xl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  station.name,
                                  style: ChargeNetTextStyles.heading(),
                                ),
                              ),
                              CnStatusBadge(
                                status: statusBadgeFor(station.statusName),
                              ),
                            ],
                          ),
                          const SizedBox(height: ChargeNetSpacing.xs),
                          Text(
                            station.address,
                            style: ChargeNetTextStyles.bodySm(),
                          ),
                          Text(
                            station.cityName,
                            style: ChargeNetTextStyles.caption(),
                          ),
                          if (station.rating != null) ...[
                            const SizedBox(height: ChargeNetSpacing.sm),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: ChargeNetColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  station.rating!.toStringAsFixed(1),
                                  style: ChargeNetTextStyles.label(
                                    color: ChargeNetColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: ChargeNetSpacing.lg),
                          _StatsRow(station: station, availableCount: availableCount),
                          const SizedBox(height: ChargeNetSpacing.lg),
                          _TariffSection(tariffsAsync: tariffsAsync),
                          const SizedBox(height: ChargeNetSpacing.lg),
                          Text('Connectors', style: ChargeNetTextStyles.title()),
                          const SizedBox(height: ChargeNetSpacing.sm),
                          connectorsAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CnLoading(message: 'Loading connectors…'),
                            ),
                            error: (e, _) => CnErrorView(
                              message: e.toString(),
                              onRetry: () => ref.invalidate(
                                stationConnectorsProvider(stationId),
                              ),
                              expand: false,
                            ),
                            data: (connectors) {
                              if (connectors.isEmpty) {
                                return Text(
                                  'No connectors configured yet.',
                                  style: ChargeNetTextStyles.bodySm(),
                                );
                              }
                              return Column(
                                children: [
                                  for (final c in connectors) ConnectorTile(connector: c),
                                ],
                              );
                            },
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              _ActionBar(
                canNavigate: hasCoords,
                canReserve: canReserve,
                onNavigate: hasCoords
                    ? () async {
                        final ok = await openMapsNavigation(
                          lat: station.latitude!,
                          lng: station.longitude!,
                        );
                        if (!context.mounted) return;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open maps'),
                            ),
                          );
                        }
                      }
                    : null,
                onReserve: canReserve
                    ? () => context.push('/stations/$stationId/reserve')
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.station});

  final ChargingStation station;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ChargeNetColors.background,
            Color(0xFF0F2A22),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.ev_station_rounded,
            size: 72,
            color: ChargeNetColors.primary.withValues(alpha: 0.35),
          ),
          if (station.isFastCharger)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ChargeNetSpacing.sm,
                  vertical: ChargeNetSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: ChargeNetColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(ChargeNetRadii.md),
                  border: Border.all(
                    color: ChargeNetColors.warning.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Fast charger',
                  style: ChargeNetTextStyles.caption(
                    color: ChargeNetColors.warning,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.station, required this.availableCount});

  final ChargingStation station;
  final int? availableCount;

  @override
  Widget build(BuildContext context) {
    final connectorLabel = availableCount != null
        ? '$availableCount / ${station.connectorCount} available'
        : '${station.connectorCount} connectors';

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.power_rounded,
            label: connectorLabel,
          ),
        ),
        const SizedBox(width: ChargeNetSpacing.sm),
        if (station.maxPowerKw != null)
          Expanded(
            child: _StatChip(
              icon: Icons.bolt_rounded,
              label: '${station.maxPowerKw!.toStringAsFixed(0)} kW max',
            ),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CnCard(
      child: Row(
        children: [
          Icon(icon, size: 18, color: ChargeNetColors.primary),
          const SizedBox(width: ChargeNetSpacing.sm),
          Expanded(
            child: Text(label, style: ChargeNetTextStyles.caption()),
          ),
        ],
      ),
    );
  }
}

class _TariffSection extends StatelessWidget {
  const _TariffSection({required this.tariffsAsync});

  final AsyncValue<List<Tariff>> tariffsAsync;

  @override
  Widget build(BuildContext context) {
    return tariffsAsync.when(
      loading: () => CnCard(
        child: Text('Loading tariffs…', style: ChargeNetTextStyles.bodySm()),
      ),
      error: (_, __) => CnCard(
        child: Text(
          'Tariff info unavailable',
          style: ChargeNetTextStyles.bodySm(),
        ),
      ),
      data: (tariffs) {
        if (tariffs.isEmpty) {
          return CnCard(
            child: Text(
              'No active tariffs',
              style: ChargeNetTextStyles.bodySm(),
            ),
          );
        }

        final sorted = [...tariffs]
          ..sort((a, b) => a.pricePerKwh.compareTo(b.pricePerKwh));
        final cheapest = sorted.first;
        final symbol = cheapest.currency == 'EUR' ? '€' : cheapest.currency;

        return CnCard(
          gradientBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pricing', style: ChargeNetTextStyles.label()),
              const SizedBox(height: ChargeNetSpacing.sm),
              Text(
                'From $symbol${cheapest.pricePerKwh.toStringAsFixed(2)}/kWh',
                style: ChargeNetTextStyles.title(
                  color: ChargeNetColors.primary,
                ),
              ),
              const SizedBox(height: ChargeNetSpacing.sm),
              for (final t in sorted)
                Padding(
                  padding: const EdgeInsets.only(top: ChargeNetSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(t.name, style: ChargeNetTextStyles.caption()),
                      ),
                      Text(
                        '$symbol${t.pricePerKwh.toStringAsFixed(2)}/kWh'
                        '${t.pricePerMinute != null ? ' + ${t.pricePerMinute!.toStringAsFixed(2)}/min' : ''}',
                        style: ChargeNetTextStyles.caption(
                          color: ChargeNetColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.canNavigate,
    required this.canReserve,
    required this.onNavigate,
    required this.onReserve,
  });

  final bool canNavigate;
  final bool canReserve;
  final VoidCallback? onNavigate;
  final VoidCallback? onReserve;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ChargeNetSpacing.mobileHorizontal,
        ChargeNetSpacing.md,
        ChargeNetSpacing.mobileHorizontal,
        ChargeNetSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: ChargeNetColors.surface,
        border: Border(top: BorderSide(color: ChargeNetColors.surfaceElevated)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CnButton(
              label: 'Navigate',
              variant: CnButtonVariant.secondary,
              icon: Icons.navigation_outlined,
              onPressed: canNavigate ? onNavigate : null,
            ),
          ),
          const SizedBox(width: ChargeNetSpacing.md),
          Expanded(
            child: CnButton(
              label: 'Reserve',
              icon: Icons.event_available_outlined,
              onPressed: canReserve ? onReserve : null,
            ),
          ),
        ],
      ),
    );
  }
}
