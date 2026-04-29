import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// State for the forget-password flow
class ForgetPasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ForgetPasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ForgetPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return ForgetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ForgetPasswordNotifier extends Notifier<ForgetPasswordState> {
  late final SupabaseClient _supabase;

  @override
  ForgetPasswordState build() {
    _supabase = Supabase.instance.client;
    return const ForgetPasswordState();
  }

  /// Step 1 — Send a password-reset OTP to the given email via Supabase.
  Future<void> sendResetEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Step 2 — Verify the OTP token that Supabase emailed to the user.
  /// On success, Supabase will establish a session so we can update the password.
  Future<void> verifyOtp({
    required String email,
    required String token,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to verify code. Please try again.',
      );
    }
  }

  /// Step 3 — Update the authenticated user's password after OTP verification.
  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      await _supabase.auth.signOut();
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update password. Please try again.',
      );
    }
  }

  void clearState() {
    state = const ForgetPasswordState();
  }
}

final forgetPasswordProvider =
    NotifierProvider<ForgetPasswordNotifier, ForgetPasswordState>(
      ForgetPasswordNotifier.new,
    );
