import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_barber/core/services/city_provider.dart';
import 'package:my_barber/core/services/location_provider.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/auth/auth_provider.dart';

class HomeWelcomeMessage extends ConsumerWidget {
  const HomeWelcomeMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityAsync = ref.watch(currentCityProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final user = ref.watch(currentUserProvider);

    // Get user's name
    String getUserName() {
      if (user == null) return "Guest";

      final name = user.userMetadata?['full_name'] as String?;
      if (name != null && name.isNotEmpty) {
        return name.split(' ')[0];
      }

      final email = user.email;
      if (email != null) {
        return email.split('@')[0];
      }

      return "Guest";
    }

    // Rationale dialog explaining why we need location
    void showLocationRationale() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryColor(context)),
              SizedBox(width: 8.w),
              const Text('Location Access'),
            ],
          ),
          content: const Text(
            'Halaqi uses your location to show barber shops near you and '
            'calculate distances to each shop.\n\n'
            'Please enable location permission in your device settings to '
            'get the best experience.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Maybe Later'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.h,
            children: [
              GestureDetector(
                onTap: () {
                  final loc = locationAsync.value;
                  if (loc is LocationFailure) showLocationRationale();
                },
                child: Icon(
                  Icons.location_pin,
                  color: AppColors.primaryColor(context),
                ),
              ),
              cityAsync.when(
                data: (city) => Text(
                  city,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                loading: () => SizedBox(
                  width: 100.w,
                  child: Text(
                    'Locating...',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                error: (_, __) => GestureDetector(
                  onTap: showLocationRationale,
                  child: Row(
                    children: [
                      Text(
                        'Location needed',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.info_outline,
                        size: 16.sp,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text.rich(
            TextSpan(
              text: "Welcome Back, ",
              children: [
                TextSpan(
                  text: getUserName(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            style: TextStyle(fontSize: 20.sp),
          ),
        ],
      ),
    );
  }
}
