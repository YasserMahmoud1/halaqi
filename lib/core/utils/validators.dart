/// Centralized validation utilities for form inputs
class Validators {
  Validators._();

  /// Email validation regex pattern (RFC 5322 simplified)
  static final RegExp _emailRegex = RegExp(
    r'''^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$''',
  );

  /// Password validation regex - at least one lowercase and one number
  static final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*\d)');

  /// Validates email format
  /// Returns null if valid, error message otherwise
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    if (email.length > 254) {
      return 'Email is too long';
    }

    return null;
  }

  /// Validates password strength
  /// Returns null if valid, error message otherwise
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password is too long';
    }

    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }

    // Check for common patterns
    if (value.toLowerCase().contains('password') ||
        value.toLowerCase().contains('12345')) {
      return 'Password is too common';
    }

    return null;
  }

  /// Validates password confirmation matches
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates full name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final name = value.trim();

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 100) {
      return 'Name is too long';
    }

    // Check for at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(name)) {
      return 'Name must contain letters';
    }

    return null;
  }

  /// Validates phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim().replaceAll(RegExp(r'[\s-]'), '');

    if (phone.length < 9) {
      return 'Phone number is too short';
    }

    if (phone.length > 15) {
      return 'Phone number is too long';
    }

    if (!RegExp(r'^[0-9+]+$').hasMatch(phone)) {
      return 'Phone number can only contain numbers and +';
    }

    return null;
  }

  /// Validates OTP code
  static String? validateOTP(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'OTP code is required';
    }

    if (value.length != length) {
      return 'OTP must be $length digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }
}
