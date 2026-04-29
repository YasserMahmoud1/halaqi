enum RouteName {
  onboarding("onboarding"),

  login("login"),
  forgetPassword("forget-password"),
  forgetPasswordOTP("forget-password-otp"),
  resetPassword("reset-password"),

  register("register"),
  registerOTP("register-otp"),

  locationPermissionGating("location-permission-gating"),

  home("home"),
  search("search"),

  barberDetails("barber-details"),
  booking("booking"),
  bookingDetails("booking-details"),

  profile("profile");

  final String value;
  const RouteName(this.value);
}
