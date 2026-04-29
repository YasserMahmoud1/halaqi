import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/api/booking_api_service.dart';
import '../data/repository/booking_repository.dart';
import '../data/models/time_slot_model.dart';
import 'booking_slots_notifier.dart';

/// Provider for Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for Booking API Service
final bookingApiServiceProvider = Provider<BookingApiService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return BookingApiService(supabase);
});

/// Provider for Booking Repository
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiService = ref.watch(bookingApiServiceProvider);
  return BookingRepository(apiService);
});

/// Provider for Booking Slots Notifier
final bookingSlotsNotifierProvider =
    AsyncNotifierProvider<BookingSlotsNotifier, List<TimeSlot>>(() {
      return BookingSlotsNotifier();
    });
