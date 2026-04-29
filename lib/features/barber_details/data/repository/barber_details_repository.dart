import 'package:flutter/foundation.dart';
import 'package:my_barber/features/barber_details/data/models/barber_details_request/barber_details_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/barber_details_api_service.dart';
import '../models/barber_details_response/barber_details_model.dart';

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

class ShopDetailsRepository {
  final BarberDetailsApiService _apiService;

  ShopDetailsRepository(this._apiService);

  /// Fetches shop details using the get_shop_details RPC
  Future<Result<BarberDetailsResponse>> getShopDetails({
    required BarberDetailsRequest request,
  }) async {
    try {
      final shopDetails = await _apiService.getShopDetails(
        request: request,
      );
      return Result.success(shopDetails);
    } on PostgrestException catch (e) {
      if (kDebugMode) debugPrint('🔴 [BarberDetailsRepository] Database error: ${e.message}');
      return Result.failure(RepositoryError('Unable to fetch shop details. Please try again.', e));
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('🔴 [BarberDetailsRepository] Error: ${e.toString()}');
      return Result.failure(
        RepositoryError('Unable to fetch shop details. Please try again.', e),
      );
    } catch (e) {
      return Result.failure(
        RepositoryError('Unable to fetch shop details. Please try again.'),
      );
    }
  }
}
