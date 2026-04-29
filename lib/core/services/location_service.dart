import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_barber/core/router/app_routers.dart';
import 'package:my_barber/core/themes/app_colors.dart';

/// Result of a location request
sealed class LocationResult {
  const LocationResult();
}

class LocationSuccess extends LocationResult {
  final Position position;
  const LocationSuccess(this.position);
}

class LocationFailure extends LocationResult {
  final LocationError error;
  const LocationFailure(this.error);
}

enum LocationError {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}

class LocationService {
  Future<LocationResult> getCurrentLocation({
    /// If true, shows the permission dialog explaining why location is needed.
    /// Set to false when permission is already granted or being managed by another screen.
    bool showDialog = true,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationFailure(LocationError.serviceDisabled);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (showDialog) {
        final shouldRequest = await _showLocationDisclosure();

        if (!shouldRequest) {
          return const LocationFailure(LocationError.permissionDenied);
        }
      }

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationFailure(LocationError.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationFailure(LocationError.permissionDeniedForever);
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    // 1. Try to get the last known position first (much faster)
    try {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return LocationSuccess(lastKnownPosition);
      }
    } catch (e) {
      // Ignore errors from getLastKnownPosition
    }

    // 2. If no last known position, fetch current position
    try {
      final position = await Geolocator.getCurrentPosition();
      return LocationSuccess(position);
    } catch (e) {
      return const LocationFailure(LocationError.unknown);
    }
  }

  double calculateDistance(
    double startLat,
    double startLong,
    double endLat,
    double endLong,
  ) {
    // Returns distance in meters
    return Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
  }

  Future<bool> _showLocationDisclosure() async {
    final disclosureContext = rootNavigatorKey.currentContext;
    if (disclosureContext == null) {
      return false;
    }

    return await showDialog<bool>(
          context: disclosureContext,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.scaffoldBackground(dialogContext),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primaryColor(dialogContext),
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Location Services',
                    style: TextStyle(
                      color: AppColors.inverseScaffoldBackground(dialogContext),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Halaqy needs access to your location to show you the nearest barber shops, calculate your distance to them, and let you find currently available barbers in your area.',
              style: TextStyle(
                color: AppColors.textGrey(dialogContext),
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textGrey(dialogContext),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor(
                    dialogContext,
                  ).withValues(alpha: 0.1),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: AppColors.primaryColor(dialogContext),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
