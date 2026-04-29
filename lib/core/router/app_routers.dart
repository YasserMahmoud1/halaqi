import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/auth/auth_provider.dart';
import 'package:my_barber/core/router/route_names.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/services/location_permission_provider.dart';
import 'package:my_barber/features/on_boarding/logic/onboarding_provider.dart';
import 'package:my_barber/features/barber_details/presentation/screens/barber_details.dart';
import 'package:my_barber/features/location_permission_gating/presentation/screens/location_permission_gating_screen.dart';
import 'package:my_barber/features/my_booking/presentation/screens/booking.dart';
import 'package:my_barber/features/my_booking/presentation/screens/booking_details.dart';
import 'package:my_barber/features/home/presentation/screens/home.dart';
import 'package:my_barber/features/profile/presentation/profile.dart';
import 'package:my_barber/features/home/presentation/screens/search_screen.dart';
import 'package:my_barber/features/home/presentation/screens/view_all_shops_screen.dart';
import 'package:my_barber/features/home_layout/home_layout.dart';
import 'package:my_barber/features/login/presentation/forget_password/forget_password.dart';
import 'package:my_barber/features/login/presentation/forget_password_otp/forget_password_otp.dart';
import 'package:my_barber/features/login/presentation/login_screen.dart';
import 'package:my_barber/features/login/presentation/reset_password/reset_password.dart';
import 'package:my_barber/features/on_boarding/presentation/onboarding_screen.dart';
import 'package:my_barber/features/register/presentation/screens/register_otp.dart';
import 'package:my_barber/features/register/presentation/screens/register_screen.dart';
import 'package:my_barber/features/splash/presentation/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<Object?>(null);

  ref.listen(authStateProvider, (_, next) {
    notifier.value = next;
  });

  ref.listen(isOnboardingCompletedProvider, (_, next) {
    notifier.value = next;
  });

  ref.listen(locationPermissionProvider, (_, next) {
    notifier.value = next;
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isOnboardingCompleted = ref.read(isOnboardingCompletedProvider);
      final locationPermission = ref.read(locationPermissionProvider);

      final isLoggedIn = authState.value?.session != null;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isAuthRoute =
          state.matchedLocation.startsWith("/${RouteName.login.value}") ||
          state.matchedLocation.startsWith("/${RouteName.register.value}");
      final isLocationPermissionGating =
          state.matchedLocation == AppRoutes.locationPermissionGating;

      final isResetFlow =
          state.matchedLocation.contains(RouteName.resetPassword.value) ||
          state.matchedLocation.contains(RouteName.forgetPassword.value);
      final isRegisterOTP = state.matchedLocation.contains(
        RouteName.registerOTP.value,
      );

      // 1. If onboarding not completed, force onboarding
      if (!isOnboardingCompleted) {
        return isOnboarding ? null : AppRoutes.onboarding;
      }

      // 2. If onboarding is completed but user is on onboarding page
      if (isOnboardingCompleted && isOnboarding) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      // 3. If not logged in and not on an auth route, force login
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      // 4. If logged in and on an auth route, go home (unless in the middle of reset password flow or register OTP)
      if (isLoggedIn && isAuthRoute && !isResetFlow && !isRegisterOTP) {
        return AppRoutes.home;
      }

      // 5. If logged in and onboarding completed, check location permission
      if (isLoggedIn && isOnboardingCompleted) {
        final hasLocationPermission = locationPermission.maybeWhen(
          data: (hasPermission) => hasPermission,
          orElse: () => false, // Default to false if loading or error
        );

        // If location permission not granted and not already on the gating screen, redirect
        if (!hasLocationPermission && !isLocationPermissionGating) {
          return AppRoutes.locationPermissionGating;
        }

        // If on gating screen but permission is now granted, go to home
        if (hasLocationPermission && isLocationPermissionGating) {
          return AppRoutes.home;
        }
      }

      // 6. If at splash screen
      if (state.matchedLocation == AppRoutes.splash) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        name: RouteName.onboarding.value,
        path: AppRoutes.onboarding,
        builder: (context, state) {
          return OnboardingScreen();
        },
      ),
      GoRoute(
        name: RouteName.login.value,
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(),
        routes: [
          GoRoute(
            name: RouteName.forgetPassword.value,
            path: RouteName.forgetPassword.value,
            builder: (context, state) => const ForgetPassword(),
            routes: [
              GoRoute(
                name: RouteName.forgetPasswordOTP.value,
                path: RouteName.forgetPasswordOTP.value,
                // email is passed as extra from ForgetPassword screen
                builder: (context, state) => const ForgetPasswordOtp(),
              ),
            ],
          ),
          GoRoute(
            path: RouteName.resetPassword.value,
            name: RouteName.resetPassword.value,
            builder: (context, state) => const ResetPassword(),
          ),
        ],
      ),
      GoRoute(
        name: RouteName.register.value,
        path: AppRoutes.register,
        builder: (context, state) => RegisterScreen(),
        routes: [
          GoRoute(
            path: RouteName.registerOTP.value,
            name: RouteName.registerOTP.value,
            builder: (context, state) => RegisterOtp(),
          ),
        ],
      ),
      GoRoute(
        name: RouteName.locationPermissionGating.value,
        path: AppRoutes.locationPermissionGating,
        builder: (context, state) => const LocationPermissionGatingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return HomeLayout(child: child);
        },
        routes: [
          GoRoute(
            name: RouteName.home.value,
            path: AppRoutes.home,
            builder: (context, state) {
              return HomeScreen();
            },
            routes: [
              GoRoute(
                name: RouteName.search.value,
                path: RouteName.search.value,
                builder: (context, state) => SearchScreen(),
              ),
              GoRoute(
                path: 'view-all-shops/:type',
                builder: (context, state) {
                  final typeStr = state.pathParameters['type'];
                  final type = typeStr == 'recommended'
                      ? ShopListType.recommended
                      : ShopListType.nearest;
                  return ViewAllShopsScreen(listType: type);
                },
              ),
            ],
          ),
          GoRoute(
            name: RouteName.booking.value,
            path: AppRoutes.booking,
            builder: (context, state) {
              return BookingScreen();
            },
            routes: [
              GoRoute(
                name: RouteName.bookingDetails.value,
                path: RouteName.bookingDetails.value,
                builder: (context, state) => BookingDetailsScreen(),
              ),
            ],
          ),
          GoRoute(
            name: RouteName.profile.value,
            path: AppRoutes.profile,
            builder: (context, state) {
              return ProfileScreen();
            },
          ),
        ],
      ),
      GoRoute(
        name: RouteName.barberDetails.value,
        path: '${AppRoutes.barberDetails}/:shopId',
        builder: (context, state) {
          final shopId = state.pathParameters['shopId'];
          if (shopId == null || shopId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Invalid shop link.')),
            );
          }
          return BarberDetailsScreen(shopId: shopId);
        },
      ),
    ],
  );
});
