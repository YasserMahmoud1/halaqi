import 'package:supabase_flutter/supabase_flutter.dart';

class MyBookingApiService {
  final SupabaseClient _supabase;

  MyBookingApiService(this._supabase);

  Future<Map<String, dynamic>> getUpcomingBookings({
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    final response = await _supabase.rpc(
      'get_upcoming_bookings',
      params: {'p_lad': latitude, 'p_long': longitude, 'p_user_id': userId},
    );
    return _asJsonMap(response);
  }

  Future<Map<String, dynamic>> getBookingHistory({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _supabase.rpc(
      'get_booking_history',
      params: {'p_lad': latitude, 'p_long': longitude},
    );
    return _asJsonMap(response);
  }

  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    final response = await _supabase.rpc(
      'get_history_booking_update',
      params: {'p_booking_id': bookingId},
    );
    return _asJsonMap(response);
  }

  Future<void> addReview({
    required String bookingId,
    required String shopId,
    required int rating,
    required String review,
  }) async {
    await _supabase.rpc(
      'add_review',
      params: {
        'p_booking_id': bookingId,
        'p_shop_id': shopId,
        'p_rating': rating,
        'p_review': review,
      },
    );
  }

  Future<void> cancelBooking(String bookingId) async {
    await _supabase.rpc('cancel_booking', params: {'p_booking_id': bookingId});
  }

  Map<String, dynamic> _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const FormatException('Invalid server response format.');
  }
}
