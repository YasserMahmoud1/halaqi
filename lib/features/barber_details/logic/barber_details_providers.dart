import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/supabase/supabase_provider.dart';
import '../data/api/barber_details_api_service.dart';
import '../data/models/barber_details_response/barber_details_model.dart';
import '../data/repository/barber_details_repository.dart';
import 'barber_details_notifier.dart';

// API Service Provider
final shopDetailsApiServiceProvider = Provider<BarberDetailsApiService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return BarberDetailsApiService(supabase);
});

// Repository Provider
final shopDetailsRepositoryProvider = Provider<ShopDetailsRepository>((ref) {
  final apiService = ref.watch(shopDetailsApiServiceProvider);
  return ShopDetailsRepository(apiService);
});

// Shop Details Notifier Provider
final shopDetailsNotifierProvider =
    AsyncNotifierProvider<BarberDetailsNotifier, BarberDetails>(() {
      return BarberDetailsNotifier();
    });
