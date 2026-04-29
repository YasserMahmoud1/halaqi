import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentSessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session;
});

// Provider to get current user
final currentUserProvider = Provider<User?>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.user;
});
