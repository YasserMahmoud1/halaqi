import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/shared_preferences/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsService(sharedPrefs);
});
