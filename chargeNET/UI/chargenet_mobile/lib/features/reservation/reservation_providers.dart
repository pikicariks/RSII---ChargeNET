import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reservationProvider =
    FutureProvider.family<Reservation, int>((ref, id) async {
  final api = await ref.watch(chargeNetApiProvider.future);
  return api.getReservation(id);
});
