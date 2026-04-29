import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// State to track loading and error
class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          errorMessage, // Reset error if not provided (or handle explicitly)
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  late final SupabaseClient _supabase;

  @override
  LoginState build() {
    _supabase = Supabase.instance.client;
    return LoginState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Login failed: No user returned",
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred",
      );
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // Handle error implicitly or add failure state
    }
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(() {
  return LoginNotifier();
});
