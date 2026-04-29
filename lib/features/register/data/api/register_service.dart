import 'package:my_barber/features/register/data/api/register_constants.dart';
import 'package:my_barber/features/register/data/models/register_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class to handle authentication operations with Supabase
class RegisterService {
  final SupabaseClient _supabase;

  /// Timeout duration for network requests
  static const Duration _requestTimeout = Duration(seconds: 30);

  RegisterService(this._supabase);

  /// Signs up a new user with email and password
  ///
  /// Throws [TimeoutException] if request takes longer than [_requestTimeout]
  /// Throws [AuthException] for authentication-related errors
  Future<AuthResponse> signUp({required RegisterModel registerModel}) async {
    return await _supabase.auth
        .signUp(
          email: registerModel.email,
          password: registerModel.password,
          data: {
            RegisterConstants.fullNameKey: registerModel.fullName,
            RegisterConstants.phoneNumberKey: registerModel.phoneNumber,
          },
        )
        .timeout(
          _requestTimeout,
          onTimeout: () => throw TimeoutException(
            'Registration request timed out',
            _requestTimeout,
          ),
        );
  }

  /// Verifies OTP code sent to user's email
  ///
  /// Throws [TimeoutException] if request takes longer than [_requestTimeout]
  /// Throws [AuthException] for authentication-related errors
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _supabase.auth
        .verifyOTP(token: token, type: OtpType.signup, email: email)
        .timeout(
          _requestTimeout,
          onTimeout: () => throw TimeoutException(
            'OTP verification timed out',
            _requestTimeout,
          ),
        );
  }

  /// Resends OTP code to user's email
  ///
  /// Throws [TimeoutException] if request takes longer than [_requestTimeout]
  /// Throws [AuthException] for authentication-related errors
  Future<ResendResponse> resendOtp({required String email}) async {
    return await _supabase.auth
        .resend(type: OtpType.signup, email: email)
        .timeout(
          _requestTimeout,
          onTimeout: () => throw TimeoutException(
            'Resend OTP request timed out',
            _requestTimeout,
          ),
        );
  }
}

/// Custom timeout exception for better error handling
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message after ${timeout.inSeconds}s';
}
