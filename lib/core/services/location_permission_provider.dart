import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Async notifier to manage location permission state with refresh capability
class LocationPermissionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Manually refresh permission state after user grants permission
  Future<void> refreshPermission() async {
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider to track location permission state with refresh capability
/// Use .notifier to access refreshPermission() after permission grant
final locationPermissionProvider =
    AsyncNotifierProvider<LocationPermissionNotifier, bool>(
  LocationPermissionNotifier.new,
);

/// Provider to check the current location permission status
final currentLocationPermissionProvider = FutureProvider<LocationPermission>((
  ref,
) async {
  return await Geolocator.checkPermission();
});
