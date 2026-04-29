import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/services/location_provider.dart';
import '../data/models/search_result_model.dart';
import 'home_providers.dart';

/// State class for search
class SearchState {
  final List<SearchShopItemModel> results;
  final bool isLoading;
  final String? error;
  final String query;

  SearchState({
    required this.results,
    required this.isLoading,
    this.error,
    required this.query,
  });

  SearchState.initial()
    : results = [],
      isLoading = false,
      error = null,
      query = '';

  SearchState copyWith({
    List<SearchShopItemModel>? results,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      query: query ?? this.query,
    );
  }
}

/// Search Notifier with debounce mechanism
class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  // Debounce duration - user must stop typing for this duration before search is triggered
  static const _debounceDuration = Duration(milliseconds: 500);

  @override
  SearchState build() {
    // Cleanup timer when the provider is disposed
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return SearchState.initial();
  }

  /// Search for shops with debounce
  /// This method will be called on every keystroke, but will only trigger
  /// the actual search after the user stops typing for the debounce duration
  void search(String query) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Update the query immediately (for UI feedback if needed)
    state = state.copyWith(query: query);

    // If query is empty, clear results
    if (query.trim().isEmpty) {
      state = SearchState.initial();
      return;
    }

    // Set loading state
    state = state.copyWith(isLoading: true, error: null);

    // Create a new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(query.trim());
    });
  }

  /// Perform the actual search
  Future<void> _performSearch(String query) async {
    try {
      // Get repository
      final repository = ref.read(shopRepositoryProvider);

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
              errorMessage = 'Location permissions are permanently denied.';
              break;
            case LocationError.unknown:
              errorMessage = 'Unknown location error.';
              break;
          }
        }

        state = state.copyWith(isLoading: false, error: errorMessage);
        return;
      }

      final position = locationResult.position;

      // Call repository search method
      final result = await repository.searchShops(
        query: query,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          results: result.data!.results,
          isLoading: false,
          error: null,
        );
      } else if (result.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to search shops',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Clear search results
  void clear() {
    _debounceTimer?.cancel();
    state = SearchState.initial();
  }
}
