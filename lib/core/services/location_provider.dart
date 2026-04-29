import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_barber/core/services/location_service.dart';
export 'package:my_barber/core/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provides user location. Does not request permission; assumes permission
/// has been granted by the permission gating screen.
final userLocationProvider = FutureProvider<LocationResult>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  // showDialog: false because permission should already be granted
  // or we want to handle the failure gracefully in home screen
  return await locationService.getCurrentLocation(showDialog: false);
});
