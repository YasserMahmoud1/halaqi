import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'location_provider.dart';

/// Provider that gets the current city name from coordinates
final currentCityProvider = FutureProvider<String>((ref) async {
  final locationAsync = ref.watch(userLocationProvider);

  return locationAsync.when(
    data: (locationResult) async {
      if (locationResult is! LocationSuccess) {
        return 'Unknown Location';
      }

      final position = locationResult.position;

      try {
        // Reverse geocode to get city name
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Try to get city, locality, or administrative area
          return place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              'Unknown City';
        }

        return 'Unknown City';
      } catch (e) {
        return 'Unknown City';
      }
    },
    loading: () async => 'Locating...',
    error: (error, stack) async => 'Location Error',
  );
});
