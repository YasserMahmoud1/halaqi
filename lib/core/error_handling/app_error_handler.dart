import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_barber/core/error_handling/failure.dart';

class AppErrorHandler {
  static Failure handle(Object error) {
    if (error is AuthException) {
      return _handleAuthException(error);
    } else if (error is PostgrestException) {
      return ServerFailure(error.message, code: int.tryParse(error.code ?? ''));
    } else if (error is SocketException) {
      return ConnectionFailure('No Internet Connection');
    } else if (error is Failure) {
      return error;
    } else {
      return Failure('Something went wrong, please try again later');
    }
  }

  static Failure _handleAuthException(AuthException error) {
    // Custom mapping for Supabase Auth errors
    // You can inspect error.statusCode or error.message
    // Ref: https://supabase.com/docs/guides/auth/errors

    switch (error.message) {
      case 'User already registered':
        return ServerFailure('This email is already registered.');
      case 'Invalid login credentials':
        return ServerFailure('Invalid email or password.');
      default:
        return ServerFailure(error.message);
    }
  }
}
