/// Error messages used throughout the register feature
class RegisterErrorMessages {
  RegisterErrorMessages._();

  // Network errors
  static const String networkError =
      'Network error. Please check your connection and try again.';
  static const String serverError = 'Server error. Please try again later.';
  static const String timeoutError = 'Request timed out. Please try again.';

  // Registration errors
  static const String emailAlreadyExists =
      'This email is already registered. Please login instead.';
  static const String invalidCredentials =
      'Invalid registration details. Please check and try again.';
  static const String weakPassword =
      'Password is too weak. Please use a stronger password.';
  static const String registrationFailed =
      'Registration failed. Please try again.';

  // OTP errors
  static const String invalidOTP =
      'Invalid OTP code. Please check and try again.';
  static const String expiredOTP =
      'OTP code has expired. Please request a new one.';
  static const String otpVerificationFailed =
      'OTP verification failed. Please try again.';
  static const String tooManyAttempts =
      'Too many attempts. Please try again later.';

  // Resend OTP
  static const String otpResent = 'New OTP code sent to your email.';
  static const String resendFailed = 'Failed to resend OTP. Please try again.';

  // Success messages
  static const String registrationSuccess =
      'Registration successful! Please verify your email.';
  static const String accountCreated = 'Account created successfully!';
  static const String emailSent =
      'Verification email sent. Please check your inbox.';

  // Validation errors
  static const String missingEmail = 'Email address is required to proceed.';
}

/// Constants used in the register feature
class RegisterConstants {
  RegisterConstants._();

  // OTP configuration
  static const int otpLength = 6;
  static const int otpResendCooldown = 60; // seconds
  static const int otpExpiryTime = 600; // 10 minutes in seconds

  // Password requirements
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Animation durations
  static const Duration dialogDisplayDuration = Duration(milliseconds: 500);
  static const Duration loadingIndicatorDelay = Duration(milliseconds: 300);

  // Lottie animation paths
  static const String checkEmailAnimation = 'assets/lottie/check_email.json';
  static const String successAnimation = 'assets/lottie/success.json';

  // User metadata keys (for Supabase)
  static const String fullNameKey = 'full_name';
  static const String phoneNumberKey = 'phone';
}
