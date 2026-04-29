import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/booking_api_service.dart';
import '../models/time_slot_model.dart';

/// Error wrapper for repository operations
class BookingError {
  final String message;
  final Exception? exception;

  BookingError(this.message, [this.exception]);

  @override
  String toString() => message;
}

/// Result wrapper to handle success and failure cases
class BookingResult<T> {
  final T? data;
  final BookingError? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  BookingResult.success(this.data) : error = null;
  BookingResult.failure(this.error) : data = null;
}

class BookingRepository {
  final BookingApiService _apiService;

  BookingRepository(this._apiService);

  /// Fetches available time slots for booking
  Future<BookingResult<AvailableSlotsResponse>> getAvailableSlots({
    required String shopId,
    required List<String> serviceIds,
    required String date,
  }) async {
    try {
      final slotsResponse = await _apiService.getAvailableSlots(
        shopId: shopId,
        serviceIds: serviceIds,
        date: date,
      );
      return BookingResult.success(slotsResponse);
    } on PostgrestException catch (e) {
      if (kDebugMode) debugPrint('🔴 [BookingRepository] Database error: ${e.message}');
      return BookingResult.failure(
        BookingError('Unable to fetch available slots. Please try again.', e),
      );
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('🔴 [BookingRepository] Error: ${e.toString()}');
      return BookingResult.failure(
        BookingError('Unable to fetch available slots. Please try again.', e),
      );
    } catch (e) {
      return BookingResult.failure(
        BookingError('Unable to fetch available slots. Please try again.'),
      );
    }
  }

  /// Creates a new booking
  Future<BookingResult<String>> createBooking({
    required String userId,
    required String shopId,
    required DateTime fromDateTime,
    required DateTime toDateTime,
    required List<String> serviceIds,
    required double totalCost,
  }) async {
    try {
      final response = await _apiService.createBooking(
        userId: userId,
        shopId: shopId,
        fromDateTime: fromDateTime,
        toDateTime: toDateTime,
        serviceIds: serviceIds,
        totalCost: totalCost,
      );

      final bookingId = response['booking_id']?.toString();
      if (bookingId == null || bookingId.isEmpty) {
        return BookingResult.failure(
          BookingError('Booking failed: invalid booking id in response.'),
        );
      }
      return BookingResult.success(bookingId);
    } on PostgrestException catch (e) {
      if (kDebugMode) debugPrint('🔴 [BookingRepository] Database error: ${e.message}');
      return BookingResult.failure(
        BookingError('Unable to create booking. Please try again.', e),
      );
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('🔴 [BookingRepository] Error: ${e.toString()}');
      return BookingResult.failure(
        BookingError('Unable to create booking. Please try again.', e),
      );
    } catch (e) {
      return BookingResult.failure(
        BookingError('Unable to create booking. Please try again.'),
      );
    }
  }
}
