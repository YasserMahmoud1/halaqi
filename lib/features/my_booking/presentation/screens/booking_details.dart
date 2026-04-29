import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/features/my_booking/presentation/screens/rating_review_screen.dart';
import '../../logic/my_booking_providers.dart';
import '../../data/models/upcoming_booking_model.dart';
import '../../data/models/booking_history_model.dart';

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra;
    String? bookingId;
    String? bookingStatus;

    if (extra is BookingHistoryModel) {
      bookingId = extra.bookingId;
      bookingStatus = extra.status;
    } else if (extra is UpcomingBooking) {
      bookingId = extra.bookingId;
      bookingStatus = extra.status;
    } else if (extra is Map<String, dynamic> && extra['booking_id'] != null) {
      // Handle generic map case or ID string
      bookingId = extra['booking_id'].toString();
      final rawStatus = extra['status'];
      if (rawStatus is String) {
        bookingStatus = rawStatus;
      }
    }

    final isCompletedFromMap =
        extra is Map<String, dynamic> && extra['is_completed'] == true;
    final displayedStatus = _resolveDisplayedStatus(
      bookingStatus,
      isCompletedFromMap,
    );

    if (bookingId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text('Unable to open booking details.')),
      );
    }

    final resolvedBookingId = bookingId;

    final detailsAsync = ref.watch(bookingDetailsProvider(resolvedBookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text('Could not load booking details. Please try again.'),
        ),
        data: (details) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Square image with corner radius
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: details.shopCover != null
                                ? Image.network(
                                    details.shopCover!,
                                    width: double.infinity,
                                    height: 200.h,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildPlaceholder(),
                                  )
                                : _buildPlaceholder(),
                          ),
                          Positioned(
                            top: 12.h,
                            right: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBadgeColor(displayedStatus),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                displayedStatus,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Barber name (Shop Name)
                      Text(
                        details.shopName,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20.sp),
                          SizedBox(width: 4.w),
                          Text(
                            details.shopRating != null
                                ? details.shopRating!.toStringAsFixed(1)
                                : 'Not rated',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Note: Review count not provided by RPC
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Service Summary
                      Text(
                        'Service Summary',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      ...details.services.map(
                        (service) => Padding(
                          padding: EdgeInsets.only(bottom: 8.0.h),
                          child: _buildServiceItem(
                            service.name,
                            '${service.cost.toStringAsFixed(2)} SAR',
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Dotted divider
                      CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: DottedLinePainter(),
                      ),
                      SizedBox(height: 16.h),

                      // Total Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${details.totalCost.toStringAsFixed(2)} SAR',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Booking info
                      _buildInfoRow(
                        'Date',
                        DateFormat('MMM dd, yyyy').format(details.datetime),
                      ),
                      SizedBox(height: 8.h),
                      _buildInfoRow(
                        'Time',
                        DateFormat('h:mm a').format(details.datetime),
                      ),
                      SizedBox(height: 8.h),
                      _buildInfoRow(
                        'Duration',
                        '${details.totalDuration} mins',
                      ),
                    ],
                  ),
                ),
              ),

              if (details.canReview)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0.w,
                    vertical: 16.0.h,
                  ),
                  child: AppButton(
                    text: 'Rate & Review',
                    onTap: () async {
                      final reviewSubmitted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RatingReviewScreen(
                            bookingId: details.bookingId,
                            shopId: details.shopId,
                            shopName: details.shopName,
                            shopImage: details.shopCover,
                            shopRating: details.shopRating,
                            shopAddress: details.shopAddress,
                            distanceKm: details.distanceKm,
                          ),
                        ),
                      );

                      if (reviewSubmitted == true) {
                        ref.invalidate(
                          bookingDetailsProvider(resolvedBookingId),
                        );
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(Icons.store, size: 50.sp, color: Colors.grey),
    );
  }

  Widget _buildServiceItem(String service, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(service, style: TextStyle(fontSize: 16.sp)),
        Text(
          price,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _resolveDisplayedStatus(String? status, bool isCompletedFromMap) {
    final normalized = status?.trim().toLowerCase() ?? '';

    if (normalized == 'completed') return 'Completed';
    if (normalized == 'canceled' || normalized == 'cancelled') {
      return 'Canceled';
    }
    if (normalized.isNotEmpty) {
      return normalized
          .split('_')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
          )
          .join(' ');
    }

    return isCompletedFromMap ? 'Completed' : 'Pending';
  }

  Color _statusBadgeColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'completed') return const Color(0xFF3B82F6);
    if (normalized == 'canceled' || normalized == 'cancelled') {
      return Colors.red;
    }

    return const Color(0xFFF59E0B);
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
