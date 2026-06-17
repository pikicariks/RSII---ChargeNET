import 'package:chargenet_mobile/features/map/map_providers.dart';
import 'package:chargenet_mobile/features/map/station_bottom_sheet.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(mapLocationProvider);
    final recommendations = ref.watch(filteredRecommendationsProvider);
    final center = LatLng(loc.lat, loc.lng);
    final markers = recommendations.maybeWhen(
      data: (items) => [
        for (final s in items)
          if (s.latitude != null && s.longitude != null)
            Marker(
              point: LatLng(s.latitude!, s.longitude!),
              width: 44,
              height: 44,
              child: _MapPin(
                color: s.isActive
                    ? ChargeNetColors.primary
                    : ChargeNetColors.warning,
                onTap: () => context.push('/stations/${s.id}'),
              ),
            ),
      ],
      orElse: () => <Marker>[],
    );

    return Scaffold(
      backgroundColor: ChargeNetColors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ColoredBox(
                  color: ChargeNetColors.background,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: MapConstants.defaultZoom,
                      backgroundColor: ChargeNetColors.background,
                      onMapReady: () =>
                          _mapController.move(center, MapConstants.defaultZoom),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.chargenet.chargenet_mobile',
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      ChargeNetSpacing.mobileHorizontal,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CnTextField(
                            controller: _searchController,
                            hint: 'Search stations…',
                            prefixIcon:
                                const Icon(Icons.search_rounded, size: 20),
                            onChanged: (v) => ref
                                .read(mapSearchQueryProvider.notifier)
                                .state = v,
                          ),
                        ),
                        const SizedBox(width: ChargeNetSpacing.sm),
                        Material(
                          color: ChargeNetColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ChargeNetRadii.md),
                            side: const BorderSide(
                              color: ChargeNetColors.surfaceElevated,
                            ),
                          ),
                          child: IconButton(
                            tooltip: 'Center on Sarajevo',
                            onPressed: () {
                              ref
                                  .read(mapLocationProvider.notifier)
                                  .resetToSarajevo();
                              _mapController.move(
                                const LatLng(
                                  MapConstants.defaultLat,
                                  MapConstants.defaultLng,
                                ),
                                MapConstants.defaultZoom,
                              );
                            },
                            icon: const Icon(
                              Icons.my_location_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.42,
            child: StationBottomSheet(
              onStationTap: (station) =>
                  context.push('/stations/${station.id}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.onTap,
  });

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.55),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(Icons.ev_station, color: color, size: 32),
      ),
    );
  }
}
