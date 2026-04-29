import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import '../../logic/my_booking_providers.dart';
import '../../data/models/upcoming_booking_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class UpcomingBookingsList extends ConsumerStatefulWidget {
  const UpcomingBookingsList({super.key});

  @override
  ConsumerState<UpcomingBookingsList> createState() =>
      _UpcomingBookingsListState();
}

class _UpcomingBookingsListState extends ConsumerState<UpcomingBookingsList> {
  int _currentPage = 0;
  PageController? _pageController;
  final Map<String, ScrollController> _serviceScrollControllers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth > 600;
    final viewportFraction = isTablet ? 0.5 : 0.92;
    
    if (_pageController == null || _pageController!.viewportFraction != viewportFraction) {
      final oldPage = _pageController?.page?.toInt() ?? 0;
      _pageController?.dispose();
      
      _pageController = PageController(
        viewportFraction: viewportFraction,
        initialPage: oldPage,
      );
    }
  }

  ScrollController _serviceControllerFor(String bookingId) {
    return _serviceScrollControllers.putIfAbsent(
      bookingId,
      () => ScrollController(),
    );
  }

  @override
  void dispose() {
    for (final controller in _serviceScrollControllers.values) {
      controller.dispose();
    }
    _pageController?.dispose();
    super.dispose();
  }

  void _handleCancel(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.event_busy,
              color: AppColors.primaryColor(dialogContext),
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Cancel Booking',
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
          'Are you sure you want to cancel this booking?',
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
              'No',
              style: TextStyle(
                color: AppColors.textGrey(dialogContext),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext, true);
                  await ref
                      .read(cancelBookingProvider.notifier)
                      .cancelBooking(bookingId);
                },
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
                  'Yes, Cancel',
                  style: TextStyle(
                    color: AppColors.primaryColor(dialogContext),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(double lat, double long) async {
    final nativeUri = Uri.parse('geo:$lat,$long?q=$lat,$long');
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$long',
    );

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open maps right now.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(upcomingBookingsProvider);

    // Listen for cancel status
    ref.listen(cancelBookingProvider, (previous, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to cancel booking.'),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {},
      );
    });

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(
        child: Text('Could not load upcoming bookings. Please try again.'),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64.sp,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No upcoming bookings',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textGrey(context),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(context, bookings[index]);
                },
              ),
            ),
            SizedBox(height: 16.h),
            if (bookings.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  bookings.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryColor(context)
                          : Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, UpcomingBooking booking) {
    final primary = AppColors.primaryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final servicesScrollController = _serviceControllerFor(booking.bookingId);
    final servicesForUi = booking.services;
    const maxVisibleServices = 2;
    final visibleServiceCount = servicesForUi.isEmpty
        ? 1
        : (servicesForUi.length < maxVisibleServices
              ? servicesForUi.length
              : maxVisibleServices);
    final hiddenServiceCount = servicesForUi.length > maxVisibleServices
        ? servicesForUi.length - maxVisibleServices
        : 0;
    final serviceListHeight = visibleServiceCount == 1 ? 54.h : 108.h;
    final totalDuration = servicesForUi.fold<int>(
      0,
      (sum, service) => sum + service.serviceDuration,
    );
    final totalPrice = servicesForUi.fold<double>(
      0,
      (sum, service) => sum + service.servicePrice,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Shop Image & Name overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                child: booking.shopCover != null
                    ? Image.network(
                        booking.shopCover!,
                        width: double.infinity,
                        height: 140.h,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
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
                    color: _statusColor(booking.status).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    _displayStatus(booking.status),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.shopName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _openMap(booking.latitude, booking.longitude),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    booking.shopAddress,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.star, color: Colors.amber, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          booking.shopRating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service List
                  Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey(context),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (servicesForUi.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        'No services added',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textGrey(context),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: serviceListHeight,
                      child: Scrollbar(
                        controller: servicesScrollController,
                        thumbVisibility: hiddenServiceCount > 0,
                        trackVisibility: hiddenServiceCount > 0,
                        thickness: 3,
                        radius: Radius.circular(10.r),
                        child: ListView.separated(
                          controller: servicesScrollController,
                          padding: EdgeInsets.only(right: 8.w),
                          physics: hiddenServiceCount > 0
                              ? const BouncingScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          itemCount: servicesForUi.length,
                          separatorBuilder: (ctx, i) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final service = servicesForUi[index];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 4.r,
                                  backgroundColor: primary,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    service.serviceName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${service.serviceDuration} min',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${service.servicePrice.toStringAsFixed(2)} SAR',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            AppColors.inverseScaffoldBackground(
                                              context,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  if (hiddenServiceCount > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h, bottom: 2.h),
                      child: Text(
                        '+$hiddenServiceCount more service${hiddenServiceCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Divider(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Time',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$totalDuration min',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inverseScaffoldBackground(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(2)} SAR',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Date & Time Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: primary,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _formatDateSimple(booking.dateAndTime),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Cancel Button
                      ElevatedButton(
                        onPressed: () =>
                            _handleCancel(context, booking.bookingId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          foregroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 140.h,
      color: Colors.grey.withValues(alpha: 0.3),
      child: Icon(Icons.store, color: Colors.grey, size: 40.sp),
    );
  }

  String _formatDateSimple(DateTime date) {
    return DateFormat('MMM dd, hh:mm a').format(date);
  }

  String _displayStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'confirmed') return 'Confirmed';
    return 'Pending';
  }

  Color _statusColor(String status) {
    if (status.trim().toLowerCase() == 'confirmed') {
      return const Color(0xFF22C55E);
    }

    return const Color(0xFFF59E0B);
  }
}
