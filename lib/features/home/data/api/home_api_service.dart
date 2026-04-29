import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/home_data_model.dart';
import '../models/search_result_model.dart';

class HomeApiService {
  final SupabaseClient _supabase;

  HomeApiService(this._supabase);

  /// Calls the get_home_data RPC to fetch recommended and nearest shops
  /// based on current location coordinates
  Future<HomeDataModel> getHomeData({
    required double latitude,
    required double longitude,
  }) async {
    if (kDebugMode) {
      debugPrint('🔵 [HomeApiService] Calling get_home_data RPC');
    }

    final response = await _supabase.rpc(
      'get_home_data',
      params: {
        'p_lad': latitude,
        'p_long': longitude,
      }, // Fixed: p_lad not p_lat
    );

    if (kDebugMode) {
      debugPrint('🟢 [HomeApiService] get_home_data RPC success');
    }

    // The RPC returns a single object with recommended and nearest arrays
    final homeData = HomeDataModel.fromJson(_asJsonMap(response));
    if (kDebugMode) {
      debugPrint(
        '🟢 [HomeApiService] Parsed data - recommended: ${homeData.recommended.length}, nearest: ${homeData.nearest.length}',
      );
    }

    return homeData;
  }

  /// Calls the search_barber_shops RPC to search for shops by name
  /// based on query and current location coordinates
  Future<SearchResultsModel> searchBarberShops({
    required String query,
    required double latitude,
    required double longitude,
  }) async {
    if (kDebugMode) {
      debugPrint('🔵 [HomeApiService] Calling search_barber_shops RPC');
    }

    final response = await _supabase.rpc(
      'search_barber_shops',
      params: {'p_query': query, 'p_lad': latitude, 'p_long': longitude},
    );

    if (kDebugMode) {
      debugPrint('🟢 [HomeApiService] search_barber_shops RPC success');
    }

    // The RPC returns an object with a results array
    final searchResults = SearchResultsModel.fromJson(_asJsonMap(response));
    if (kDebugMode) {
      debugPrint(
        '🟢 [HomeApiService] Parsed search results: ${searchResults.results.length} shops found',
      );
    }

    return searchResults;
  }

  Map<String, dynamic> _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const FormatException('Invalid server response format.');
  }
}
