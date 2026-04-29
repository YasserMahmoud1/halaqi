import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/home_api_service.dart';
import '../models/home_data_model.dart';
import '../models/shop_model.dart';
import '../models/search_result_model.dart';

/// Error wrapper for repository operations
class RepositoryError {
  final String message;
  final Exception? exception;

  RepositoryError(this.message, [this.exception]);

  @override
  String toString() => message;
}

/// Result wrapper to handle success and failure cases
class Result<T> {
  final T? data;
  final RepositoryError? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  Result.success(this.data) : error = null;
  Result.failure(this.error) : data = null;
}

class ShopRepository {
  final SupabaseClient _supabase;
  final HomeApiService _apiService;

  ShopRepository(this._supabase, this._apiService);

  /// Fetches home data using the unified get_home_data RPC
  /// Returns both recommended and nearest shops in a single call
  Future<Result<HomeDataModel>> getHomeData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final homeData = await _apiService.getHomeData(
        latitude: latitude,
        longitude: longitude,
      );
      return Result.success(homeData);
    } on PostgrestException catch (e) {
      if (kDebugMode) debugPrint('🔴 [ShopRepository] Database error: ${e.message}');
      return Result.failure(RepositoryError('Unable to fetch home data. Please try again.', e));
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('🔴 [ShopRepository] Error: ${e.toString()}');
      return Result.failure(
        RepositoryError('Unable to fetch home data. Please try again.', e),
      );
    } catch (e) {
      return Result.failure(
        RepositoryError('Unable to fetch home data. Please try again.'),
      );
    }
  }

  /// Searches for barber shops by name using the search_barber_shops RPC
  /// Returns search results based on query and user location
  Future<Result<SearchResultsModel>> searchShops({
    required String query,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final searchResults = await _apiService.searchBarberShops(
        query: query,
        latitude: latitude,
        longitude: longitude,
      );
      return Result.success(searchResults);
    } on PostgrestException catch (e) {
      if (kDebugMode) debugPrint('🔴 [ShopRepository] Database error: ${e.message}');
      return Result.failure(RepositoryError('Unable to search shops. Please try again.', e));
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('🔴 [ShopRepository] Error: ${e.toString()}');
      return Result.failure(
        RepositoryError('Unable to search shops. Please try again.', e),
      );
    } catch (e) {
      return Result.failure(
        RepositoryError('Unable to search shops. Please try again.'),
      );
    }
  }

  // Legacy methods kept for backward compatibility during migration
  // // TODO: Remove these after full migration to getHomeData()

  Future<List<ShopModel>> getNearbyShops({
    double lat = 0,
    double long = 0,
  }) async {
    try {
      // Use standard select to ensure we get all relations for accurate ratings
      // We will filter/sort by distance on the client side
      final response = await _supabase
          .from('shops')
          .select('*, shop_images(image_url), reviews(rating)')
          .limit(50);

      return (response as List)
          .map((data) => ShopModel.fromJson(data))
          .toList();

      /* 
      // RPC implementation commented out to fix data embedding issues
      final response = await _supabase
          .rpc('nearby_shops', params: {'lat': lat, 'long': long})
          .select('*, shop_images(image_url), bookings(reviews(rating))');

      return (response as List).map((data) => ShopModel.fromJson(data)).toList();
      */
    } catch (e) {
      // Fallback
      return [];
    }
  }

  Future<List<ShopModel>> getRecommendedShops() async {
    try {
      final response = await _supabase
          .from('shops')
          .select('*, shop_images(image_url), reviews(rating)')
          .limit(5);

      return (response as List)
          .map((data) => ShopModel.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
