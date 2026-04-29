import 'package:flutter/foundation.dart';
import '../models/upcoming_booking_model.dart';
import '../models/booking_history_model.dart';
import '../models/booking_details_model.dart';
import '../api/my_booking_api_service.dart';

class MyBookingRepository {
  final MyBookingApiService _apiService;

  MyBookingRepository(this._apiService);

  Future<List<UpcomingBooking>> getUpcomingBookings({
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    try {
      final response = await _apiService.getUpcomingBookings(
        latitude: latitude,
        longitude: longitude,
        userId: userId,
      );

      final bookingsList = response['bookings'] as List<dynamic>?;

      if (bookingsList == null) return [];

      return bookingsList
          .map((e) => UpcomingBooking.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error in MyBookingRepository.getUpcomingBookings: $e');
      rethrow;
    }
  }

  Future<List<BookingHistoryModel>> getBookingHistory({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiService.getBookingHistory(
        latitude: latitude,
        longitude: longitude,
      );

      final historyList = response['history'] as List<dynamic>?;

      if (historyList == null) return [];

      return historyList
          .map((e) => BookingHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error in MyBookingRepository.getBookingHistory: $e');
      rethrow;
    }
  }

  Future<BookingDetailsModel> getBookingDetails(String bookingId) async {
    try {
      final response = await _apiService.getBookingDetails(bookingId);
      return BookingDetailsModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in MyBookingRepository.getBookingDetails: $e');
      rethrow;
    }
  }

  Future<void> addReview({
    required String bookingId,
    required String shopId,
    required int rating,
    required String review,
  }) async {
    try {
      await _apiService.addReview(
        bookingId: bookingId,
        shopId: shopId,
        rating: rating,
        review: review,
      );
    } catch (e) {
      debugPrint('Error in MyBookingRepository.addReview: $e');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _apiService.cancelBooking(bookingId);
    } catch (e) {
      debugPrint('Error in MyBookingRepository.cancelBooking: $e');
      rethrow;
    }
  }
}
