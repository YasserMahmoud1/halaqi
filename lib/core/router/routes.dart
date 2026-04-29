import 'package:my_barber/core/router/route_names.dart';

class AppRoutes {
  static const String splash = '/';

  static final String onboarding = '/${RouteName.onboarding.value}';

  static final String login = '/${RouteName.login.value}';
  static final String forgetPassword =
      '/${RouteName.login.value}/${RouteName.forgetPassword.value}';
  static final String forgetPasswordOTP =
      '/${RouteName.login.value}/${RouteName.forgetPassword.value}/${RouteName.forgetPasswordOTP.value}';
  static final String resetPassword =
      '/${RouteName.login.value}/${RouteName.resetPassword.value}';

  static final String register = '/${RouteName.register.value}';
  static final String registerOTP =
      '/${RouteName.register.value}/${RouteName.registerOTP.value}';

  static final String locationPermissionGating =
      '/${RouteName.locationPermissionGating.value}';

  static final String home = '/${RouteName.home.value}';
  static final String search =
      '/${RouteName.home.value}/${RouteName.search.value}';
  static final String barberDetails = '/${RouteName.barberDetails.value}';
  static final String booking = '/${RouteName.booking.value}';
  static final String bookingDetails =
      '/${RouteName.booking.value}/${RouteName.bookingDetails.value}';
  static final String profile = '/${RouteName.profile.value}';
  static final String viewAllShops =
      '/view-all-shops/:type'; // :type can be 'recommended' or 'nearest'

  const AppRoutes._();
}
