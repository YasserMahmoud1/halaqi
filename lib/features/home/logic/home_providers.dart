import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_barber/core/services/location_provider.dart';
import 'package:my_barber/core/supabase/supabase_provider.dart';
import '../data/api/home_api_service.dart';
import '../data/models/home_data_model.dart';
import '../data/models/shop_model.dart';
import '../data/repository/shop_repository.dart';
import 'home_data_notifier.dart';
import 'search_notifier.dart';

// API Service Provider
final homeApiServiceProvider = Provider<HomeApiService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return HomeApiService(supabase);
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final apiService = ref.watch(homeApiServiceProvider);
  return ShopRepository(supabase, apiService);
});

// Home Data Notifier Provider - Using AsyncNotifier (Best Practice)
final homeDataNotifierProvider =
    AsyncNotifierProvider<HomeDataNotifier, HomeDataModel>(() {
      return HomeDataNotifier();
    });

final nearbyShopsProvider = FutureProvider<List<ShopModel>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  // Get actual user location
  final locationResult = await ref.watch(userLocationProvider.future);

  if (locationResult is LocationSuccess) {
    final position = locationResult.position;
    final shops = await repo.getNearbyShops(
      lat: position.latitude,
      long: position.longitude,
    );

    // Calculate distance if missing (fallback for RPC failure)
    final shopsWithDistance = shops.map((shop) {
      if (shop.distance == null && shop.lat != null && shop.long != null) {
        final distMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          shop.lat!,
          shop.long!,
        );
        return shop.copyWith(distance: distMeters / 1000);
      }
      return shop;
    }).toList();

    // Sort by distance
    shopsWithDistance.sort((a, b) {
      final distA = a.distance ?? double.infinity;
      final distB = b.distance ?? double.infinity;
      return distA.compareTo(distB);
    });

    return shopsWithDistance;
  }
  return [];
});

final recommendedShopsProvider = FutureProvider<List<ShopModel>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  final shops = await repo.getRecommendedShops();

  // Calculate distance for recommended shops too
  final locationResult = await ref.watch(userLocationProvider.future);
  if (locationResult is LocationSuccess) {
    final position = locationResult.position;
    return shops.map((shop) {
      if (shop.distance == null && shop.lat != null && shop.long != null) {
        final distMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          shop.lat!,
          shop.long!,
        );
        return shop.copyWith(distance: distMeters / 1000);
      }
      return shop;
    }).toList();
  }

  return shops;
});

// Search Notifier Provider with debounce
final searchNotifierProvider = NotifierProvider<SearchNotifier, SearchState>(
  () {
    return SearchNotifier();
  },
);
