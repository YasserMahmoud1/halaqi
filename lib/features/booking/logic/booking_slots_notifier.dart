import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/time_slot_model.dart';
import 'booking_providers.dart';

/// Notifier for managing available time slots state
class BookingSlotsNotifier extends AsyncNotifier<List<TimeSlot>> {
  @override
  Future<List<TimeSlot>> build() async {
    // Initial state is empty
    return [];
  }

  /// Fetch available slots for given shop, services, and date
  Future<void> fetchSlots({
    required String shopId,
    required List<String> serviceIds,
    required String date,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔵 [BookingSlotsNotifier] Fetching slots for shopId: $shopId, serviceIds: $serviceIds, date: $date',
      );
    }

    // Set loading state
    state = const AsyncValue.loading();

    // Fetch slots
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookingRepositoryProvider);
      final result = await repository.getAvailableSlots(
        shopId: shopId,
        serviceIds: serviceIds,
        date: date,
      );

      if (result.isSuccess && result.data != null) {
        if (kDebugMode) {
          debugPrint(
            '🟢 [BookingSlotsNotifier] Successfully fetched ${result.data!.slots.length} slots',
          );
        }
        return result.data!.slots;
      } else if (result.isFailure) {
        if (kDebugMode) debugPrint('🔴 [BookingSlotsNotifier] Error: ${result.error}');
        throw Exception(result.error?.message ?? 'Failed to fetch slots');
      }

      throw Exception('Unexpected error fetching slots');
    });
  }

  /// Clear slots (e.g., when user changes date or services)
  void clearSlots() {
    state = const AsyncValue.data([]);
  }
}
