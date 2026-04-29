import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps backend errors to user-friendly messages
/// Prevents sensitive information leakage to users
class ErrorMessageMapper {
  /// Convert any exception to a user-friendly error message
  static String getDisplayMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    // Handle AuthException
    if (error is AuthException) {
      return _mapAuthException(error);
    }

    // Handle PostgrestException
    if (error is PostgrestException) {
      return 'Unable to process your request. Please try again later.';
    }

    // Handle generic exceptions
    if (error is Exception) {
      final errorString = error.toString();

      // Don't expose Supabase URLs or database details
      if (errorString.contains('socket') ||
          errorString.contains('Connection') ||
          errorString.contains('PostgreSQL')) {
        return 'Network error. Please check your connection and try again.';
      }

      if (errorString.contains('timeout')) {
        return 'Request timed out. Please try again.';
      }

      if (errorString.contains('401') || errorString.contains('Unauthorized')) {
        return 'Your session has expired. Please log in again.';
      }

      if (errorString.contains('403') || errorString.contains('Forbidden')) {
        return 'You do not have permission to perform this action.';
      }

      if (errorString.contains('404') || errorString.contains('Not found')) {
        return 'The requested resource was not found.';
      }

      if (errorString.contains('429') || errorString.contains('rate')) {
        return 'Too many requests. Please wait a moment and try again.';
      }

      if (errorString.contains('500') || errorString.contains('Internal Server')) {
        return 'Server error. Please try again later.';
      }
    }

    return 'Something went wrong. Please try again.';
  }

  /// Map specific Supabase auth exceptions to user messages
  static String _mapAuthException(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return 'Invalid email or password. Please check and try again.';
    }

    if (message.contains('user already registered')) {
      return 'This email is already registered. Please log in or use a different email.';
    }

    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('weak password')) {
      return 'Password is too weak. Please choose a stronger password.';
    }

    if (message.contains('email not confirmed')) {
      return 'Please verify your email address before logging in.';
    }

    if (message.contains('otp') || message.contains('code')) {
      return 'Invalid or expired verification code. Please try again.';
    }

    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your connection.';
    }

    // Default auth error
    return 'Authentication failed. Please try again.';
  }

  /// Get a generic error message without exposing details
  static const String genericError =
      'An unexpected error occurred. Please try again.';

  static const String networkError =
      'Network error. Please check your connection and try again.';

  static const String timeoutError =
      'Request timed out. Please try again.';

  static const String serverError =
      'Server error. Please try again later.';
}
