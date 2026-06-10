import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Map origin for recommendations API.
class MapLocation {
  const MapLocation({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

final mapLocationProvider =
    NotifierProvider<MapLocationNotifier, MapLocation>(MapLocationNotifier.new);

class MapLocationNotifier extends Notifier<MapLocation> {
  @override
  MapLocation build() {
    return const MapLocation(
      lat: MapConstants.defaultLat,
      lng: MapConstants.defaultLng,
    );
  }

  void setLocation(double lat, double lng) {
    state = MapLocation(lat: lat, lng: lng);
  }

  void resetToSarajevo() {
    state = const MapLocation(
      lat: MapConstants.defaultLat,
      lng: MapConstants.defaultLng,
    );
  }
}

final recommendationsProvider =
    FutureProvider<List<RecommendedStation>>((ref) async {
  final loc = ref.watch(mapLocationProvider);
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getRecommendations(
    lat: loc.lat,
    lng: loc.lng,
    topN: 10,
  );
});

final mapSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredRecommendationsProvider =
    Provider<AsyncValue<List<RecommendedStation>>>((ref) {
  final async = ref.watch(recommendationsProvider);
  final query = ref.watch(mapSearchQueryProvider).trim().toLowerCase();

  return async.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (s) =>
              s.name.toLowerCase().contains(query) ||
              s.address.toLowerCase().contains(query) ||
              s.cityName.toLowerCase().contains(query),
        )
        .toList();
  });
});
