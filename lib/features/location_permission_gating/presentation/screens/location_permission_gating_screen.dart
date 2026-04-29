import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/services/location_provider.dart';
import 'package:my_barber/core/services/location_permission_provider.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class LocationPermissionGatingScreen extends ConsumerStatefulWidget {
  const LocationPermissionGatingScreen({super.key});

  @override
  ConsumerState<LocationPermissionGatingScreen> createState() =>
      _LocationPermissionGatingScreenState();
}

class _LocationPermissionGatingScreenState
    extends ConsumerState<LocationPermissionGatingScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Location Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor(context).withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 40.sp,
                  color: AppColors.primaryColor(context),
                ),
              ),
              SizedBox(height: 32.h),

              // Title
              Text(
                'Enable Location Services',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inverseScaffoldBackground(context),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // Description
              Text(
                'Halaqi needs access to your location to show you the nearest barber shops, calculate distances, and help you find available barbers in your area.',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textGrey(context),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // Benefits List
              _buildBenefitItem(
                context,
                Icons.store_rounded,
                'Find Nearby Shops',
              ),
              SizedBox(height: 16.h),
              _buildBenefitItem(
                context,
                Icons.directions_rounded,
                'Calculate Distance',
              ),
              SizedBox(height: 16.h),
              _buildBenefitItem(
                context,
                Icons.schedule_rounded,
                'Check Availability',
              ),
              SizedBox(height: 48.h),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor(context),
                    disabledBackgroundColor: AppColors.primaryColor(
                      context,
                    ).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.scaffoldBackground(context),
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.scaffoldBackground(context),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 24.sp, color: AppColors.primaryColor(context)),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.inverseScaffoldBackground(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleGetStarted() async {
    setState(() => _isLoading = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      // showDialog: false because we handle the entire UX on this screen
      final result = await locationService.getCurrentLocation(
        showDialog: false,
      );

      if (!mounted) return;

      if (result is LocationSuccess) {
        // Location granted, refresh permission state in router
        await ref.read(locationPermissionProvider.notifier).refreshPermission();
        // Navigate to home
        if (mounted) context.go(AppRoutes.home);
      } else if (result is LocationFailure) {
        if (result.error == LocationError.permissionDeniedForever) {
          _showOpenSettingsDialog();
        } else {
          _showErrorDialog('Location permission was not granted.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Error',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.inverseScaffoldBackground(context),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textGrey(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Location Permission Required',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.inverseScaffoldBackground(context),
          ),
        ),
        content: Text(
          'Please enable location permission in Settings to use Halaqi.',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textGrey(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textGrey(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openLocationSettings();
            },
            child: Text(
              'Open Settings',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
