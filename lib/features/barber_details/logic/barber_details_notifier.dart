import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/services/location_provider.dart';
import 'package:my_barber/features/barber_details/data/models/barber_details_request/barber_details_request.dart';
import '../data/models/barber_details_response/barber_details_model.dart';
import 'barber_details_providers.dart';

/// Notifier for managing shop details state
class BarberDetailsNotifier extends AsyncNotifier<BarberDetails> {
  String? _shopId;

  @override
  Future<BarberDetails> build() async {
    // Return a future that doesn't complete immediately
    // This keeps the UI in a loading state until loadShopDetails is called
    // instead of showing an error state
    return Completer<BarberDetails>().future;
  }

  /// Initialize with shop ID and fetch details
  Future<void> loadShopDetails(String shopId) async {
    _shopId = shopId;
    // Set loading state immediately
    state = const AsyncValue.loading();
    // Fetch data
    state = await AsyncValue.guard(() => _fetchShopDetails(shopId));
  }

  /// Fetch shop details from repository
  Future<BarberDetails> _fetchShopDetails(String shopId) async {
    if (kDebugMode) debugPrint('🔵 [ShopDetailsNotifier] Fetching details for shop: $shopId');

    // Get repository
    final repository = ref.read(shopDetailsRepositoryProvider);

    // Get user location
    final locationResult = await ref.read(userLocationProvider.future);

    if (locationResult is! LocationSuccess) {
      String errorMessage = 'Location not available';
      if (locationResult is LocationFailure) {
        switch (locationResult.error) {
          case LocationError.serviceDisabled:
            errorMessage = 'Location services are disabled.';
            break;
          case LocationError.permissionDenied:
            errorMessage = 'Location permissions are denied.';
            break;
          case LocationError.permissionDeniedForever:
            errorMessage =
                'Location permissions are permanently denied, we cannot request permissions.';
            break;
          case LocationError.unknown:
            errorMessage = 'Unknown location error.';
            break;
        }
      }
      throw Exception(errorMessage);
    }

    final position = locationResult.position;

    // Call repository
    final result = await repository.getShopDetails(
      request: BarberDetailsRequest(
        shopId: shopId,
        lat: position.latitude,
        long: position.longitude,
      ),
    );

    if (result.isSuccess && result.data != null) {
      if (kDebugMode) {
        debugPrint(
          '🟢 [ShopDetailsNotifier] Successfully loaded shop: ${result.data!.shop.name}',
        );
      }
      return result.data!.shop;
    } else if (result.isFailure) {
      if (kDebugMode) debugPrint('🔴 [ShopDetailsNotifier] Error: ${result.error}');
      throw Exception(result.error?.message ?? 'Failed to load shop details');
    }

    throw Exception('Unexpected error loading shop details');
  }

  /// Refresh shop details
  Future<void> refresh() async {
    if (_shopId == null || _shopId!.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchShopDetails(_shopId!));
  }
}
