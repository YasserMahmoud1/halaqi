import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/services/location_provider.dart';
import 'package:my_barber/features/home/logic/home_providers.dart';
import '../data/models/home_data_model.dart';

/// AsyncNotifier for managing home data (Riverpod 3.x - Best Practice)
class HomeDataNotifier extends AsyncNotifier<HomeDataModel> {
  @override
  Future<HomeDataModel> build() async {
    if (kDebugMode) debugPrint('🔵 [HomeDataNotifier] build() called');

    // Check if location is available without requesting permission
    final locationResult = await ref.watch(userLocationProvider.future);

    if (locationResult is LocationSuccess) {
      if (kDebugMode) debugPrint('🔵 [HomeDataNotifier] Location available, fetching...');
      return await _fetchData(
        locationResult.position.latitude,
        locationResult.position.longitude,
      );
    } else if (locationResult is LocationFailure) {
      String errorMessage = 'Location not available';
      switch (locationResult.error) {
        case LocationError.serviceDisabled:
          errorMessage = 'Location services are disabled.';
          break;
        case LocationError.permissionDenied:
          errorMessage = 'Location permissions are denied.';
          break;
        case LocationError.permissionDeniedForever:
          errorMessage = 'Location permissions are permanently denied.';
          break;
        case LocationError.unknown:
          errorMessage = 'Unknown location error.';
          break;
      }
      if (kDebugMode) debugPrint('🔴 [HomeDataNotifier] $errorMessage');
      throw Exception(errorMessage);
    }
    // Should not happen as LocationResult is sealed
    throw Exception('Unknown location state');
  }

  /// Internal method to fetch data
  Future<HomeDataModel> _fetchData(double latitude, double longitude) async {
    final repository = ref.read(shopRepositoryProvider);
    final result = await repository.getHomeData(
      latitude: latitude,
      longitude: longitude,
    );

    if (result.isSuccess) {
      if (kDebugMode) {
        debugPrint(
          '🟢 [HomeDataNotifier] Recommended: ${result.data?.recommended.length ?? 0}',
        );
        debugPrint(
          '🟢 [HomeDataNotifier] Nearest: ${result.data?.nearest.length ?? 0}',
        );
      }
      return result.data!;
    } else {
      if (kDebugMode) {
        debugPrint(
          '🔴 [HomeDataNotifier] Fetch failed: ${result.error?.message}',
        );
      }
      throw Exception(result.error?.message ?? 'Unknown error occurred');
    }
  }

  /// Fetches home data with location coordinates
  Future<void> fetchHomeData({
    required double latitude,
    required double longitude,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔵 [HomeDataNotifier] fetchHomeData called with lat: $latitude, long: $longitude',
      );
    }

    // Set loading state (AsyncValue automatically handles this)
    state = const AsyncValue.loading();
    if (kDebugMode) debugPrint('🔵 [HomeDataNotifier] State set to loading');

    // Fetch data from repository
    state = await AsyncValue.guard(() async {
      final repository = ref.read(shopRepositoryProvider);
      final result = await repository.getHomeData(
        latitude: latitude,
        longitude: longitude,
      );

      if (result.isSuccess) {
        if (kDebugMode) {
          debugPrint('🟢 [HomeDataNotifier] Data fetch SUCCESS');
          debugPrint(
            '🟢 [HomeDataNotifier] Recommended: ${result.data?.recommended.length ?? 0}',
          );
          debugPrint(
            '🟢 [HomeDataNotifier] Nearest: ${result.data?.nearest.length ?? 0}',
          );
        }

        return result.data!;
      } else {
        if (kDebugMode) {
          debugPrint('🔴 [HomeDataNotifier] Data fetch FAILED');
          debugPrint('🔴 [HomeDataNotifier] Error: ${result.error?.message}');
        }

        throw Exception(result.error?.message ?? 'Unknown error occurred');
      }
    });
  }

  /// Refresh home data
  Future<void> refresh({
    required double latitude,
    required double longitude,
  }) async {
    await fetchHomeData(latitude: latitude, longitude: longitude);
  }
}
