import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/time_slot_model.dart';

class BookingApiService {
  final SupabaseClient _supabase;

  BookingApiService(this._supabase);

  /// Calls the get_available_slots RPC to fetch available time slots
  /// for the given shop, services, and date
  Future<AvailableSlotsResponse> getAvailableSlots({
    required String shopId,
    required List<String> serviceIds,
    required String date, // Format: YYYY-MM-DD
  }) async {
    if (kDebugMode) {
      debugPrint('🔵 [BookingApiService] Calling get_available_slots RPC');
    }

    final response = await _supabase.rpc(
      'get_available_slots',
      params: {
        'p_shop_id': shopId,
        'p_services_id': serviceIds,
        'p_date': date,
      },
    );

    if (kDebugMode) {
      debugPrint('🟢 [BookingApiService] get_available_slots RPC success');
    }

    // The RPC returns an object with slots array and slot_duration
    final slotsResponse = AvailableSlotsResponse.fromJson(
      response as Map<String, dynamic>,
    );
    if (kDebugMode) {
      debugPrint(
        '🟢 [BookingApiService] Parsed ${slotsResponse.slots.length} slots with duration ${slotsResponse.slotDuration} minutes',
      );
    }
    return slotsResponse;
  }

  /// Calls the book RPC to create a new booking
  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String shopId,
    required DateTime fromDateTime,
    required DateTime toDateTime,
    required List<String> serviceIds,
    required double totalCost,
  }) async {
    if (kDebugMode) {
      debugPrint('🔵 [BookingApiService] Calling book RPC');
    }

    final response = await _supabase.rpc(
      'book',
      params: {
        'p_user_id': userId,
        'p_shop_id': shopId,
        'p_from_datetime': fromDateTime.toIso8601String(),
        'p_to_datetime': toDateTime.toIso8601String(),
        'p_services_ids': serviceIds,
        'p_total_cost': totalCost,
      },
    );

    if (kDebugMode) {
      debugPrint('🟢 [BookingApiService] book RPC success');
    }
    return response as Map<String, dynamic>;
  }
}
