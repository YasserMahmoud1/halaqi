import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_barber/core/services/location_provider.dart';
import '../data/api/my_booking_api_service.dart';
import '../data/repository/my_booking_repository.dart';
import '../data/models/upcoming_booking_model.dart';
import '../data/models/booking_history_model.dart';
import '../data/models/booking_details_model.dart';

/// API Service Provider
final myBookingApiServiceProvider = Provider<MyBookingApiService>((ref) {
  return MyBookingApiService(Supabase.instance.client);
});

/// Repository Provider
final myBookingRepositoryProvider = Provider<MyBookingRepository>((ref) {
  final apiService = ref.watch(myBookingApiServiceProvider);
  return MyBookingRepository(apiService);
});

/// Upcoming Bookings Provider
final upcomingBookingsProvider =
    FutureProvider.autoDispose<List<UpcomingBooking>>((ref) async {
      final repository = ref.watch(myBookingRepositoryProvider);

      // Non-blocking location access.
      final locationAsync = ref.watch(userLocationProvider);
      final locationResult = locationAsync.asData?.value;
      Position? position;
      if (locationResult is LocationSuccess) {
        position = locationResult.position;
      }

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('User must be logged in to view bookings');
      }

      return repository.getUpcomingBookings(
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        userId: user.id,
      );
    });

/// Booking History Provider
final bookingHistoryProvider =
    FutureProvider.autoDispose<List<BookingHistoryModel>>((ref) async {
      final repository = ref.watch(myBookingRepositoryProvider);

      final locationAsync = ref.watch(userLocationProvider);
      final locationResult = locationAsync.asData?.value;
      Position? position;
      if (locationResult is LocationSuccess) {
        position = locationResult.position;
      }

      return repository.getBookingHistory(
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
      );
    });

/// Booking Details Provider (Family)
final bookingDetailsProvider = FutureProvider.autoDispose
    .family<BookingDetailsModel, String>((ref, bookingId) async {
      final repository = ref.watch(myBookingRepositoryProvider);
      return repository.getBookingDetails(bookingId);
    });

/// Add Review Notifier
final addReviewProvider = AsyncNotifierProvider<AddReviewNotifier, void>(
  AddReviewNotifier.new,
);

class AddReviewNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is void/null
  }

  Future<void> submitReview({
    required String bookingId,
    required String shopId,
    required int rating,
    required String review,
  }) async {
    final repository = ref.read(myBookingRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repository.addReview(
        bookingId: bookingId,
        shopId: shopId,
        rating: rating,
        review: review,
      ),
    );
  }
}

/// Cancel Booking Notifier
final cancelBookingProvider =
    AsyncNotifierProvider<CancelBookingNotifier, void>(
      CancelBookingNotifier.new,
    );

class CancelBookingNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is void/null
  }

  Future<void> cancelBooking(String bookingId) async {
    final repository = ref.read(myBookingRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.cancelBooking(bookingId));

    // Refresh the upcoming bookings list and history after cancellation
    if (!state.hasError) {
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(bookingHistoryProvider);
    }
  }
}
