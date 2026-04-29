import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/services/location_provider.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import '../../logic/my_booking_providers.dart';

class HistoryBookingsList extends ConsumerWidget {
  const HistoryBookingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(bookingHistoryProvider);
    final userLocationAsync = ref.watch(userLocationProvider);

    final locationResult = userLocationAsync.asData?.value;
    final userPosition = locationResult is LocationSuccess
        ? locationResult.position
        : null;

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(
        child: Text('Could not load booking history. Please try again.'),
      ),
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64.sp,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No booking history',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textGrey(context),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final booking = history[index];
            return InkWell(
              onTap: () {
                context.push(AppRoutes.bookingDetails, extra: booking);
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: SizedBox(
                  height: 100.h,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: booking.shopCover != null
                            ? Image.network(
                                booking.shopCover!,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              booking.shopName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.inverseScaffoldBackground(
                                  context,
                                ),
                              ),
                            ),
                            // Date Display
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatDate(booking.datetime),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.textGrey(context),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      booking.status,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999.r),
                                    border: Border.all(
                                      color: _statusColor(
                                        booking.status,
                                      ).withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    _statusLabel(booking.status),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: _statusColor(booking.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      color: AppColors.primaryColor(context),
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _calculateDistance(
                                        userPosition,
                                        booking.latitude,
                                        booking.longitude,
                                      ),
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 12.w),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.primaryColor(context),
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      booking.shopRating != null
                                          ? (booking.shopRating
                                                    ?.toStringAsFixed(1) ??
                                                '0.0')
                                          : 'Not rated',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: booking.shopRating == null
                                            ? Colors.grey
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 100.h,
      width: 100.w,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.store, color: Colors.grey),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _calculateDistance(
    Position? userPos,
    double shopLat,
    double shopLong,
  ) {
    if (userPos == null) return 'N/A';
    final distanceInMeters = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      shopLat,
      shopLong,
    );
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }

  String _statusLabel(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'completed') return 'Completed';
    if (normalized == 'canceled' || normalized == 'cancelled') {
      return 'Canceled';
    }

    return 'Completed';
  }

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}
