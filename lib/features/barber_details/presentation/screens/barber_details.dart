import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/utils/error_message_mapper.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/features/barber_details/logic/barber_details_providers.dart';
import 'package:my_barber/features/booking/presentation/screens/booking_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class BarberDetailsScreen extends ConsumerStatefulWidget {
  final String shopId;

  const BarberDetailsScreen({super.key, required this.shopId});

  @override
  ConsumerState<BarberDetailsScreen> createState() =>
      _BarberDetailsScreenState();
}

class _BarberDetailsScreenState extends ConsumerState<BarberDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _photoPageController = PageController();

  int _currentPhotoIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load shop details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopDetailsNotifierProvider.notifier)
          .loadShopDetails(widget.shopId);
    });

    // Update open/closed status every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _photoPageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Check if shop is currently open based on working hours
  bool _isShopOpen(List workingDays) {
    if (workingDays.isEmpty) return false;

    final now = DateTime.now();
    final currentDayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
    final currentTime = TimeOfDay.now();

    // Find today's working hours
    final todayHours = workingDays
        .where((day) => day.dayOfWeek == currentDayOfWeek)
        .toList();

    if (todayHours.isEmpty) return false;

    try {
      final day = todayHours.first;
      if (day.opensAt == null || day.closesAt == null) return false;

      final opensAt = _parseTimeString(day.opensAt!);
      final closesAt = _parseTimeString(day.closesAt!);

      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final openMinutes = opensAt.hour * 60 + opensAt.minute;
      final closeMinutes = closesAt.hour * 60 + closesAt.minute;

      return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
    } catch (e) {
      return false;
    }
  }

  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    final shopDetailsAsync = ref.watch(shopDetailsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: shopDetailsAsync.when(
            data: (shopDetails) {
              final isOpen = _isShopOpen(shopDetails.workingDays);

              return SafeArea(
                child: Column(
              children: [
                // Header with photos carousel, open/closed badge, and back button
                _buildPhotoHeader(context, shopDetails.photos, isOpen),

                // Barber info card with maps button
                _buildBarberInfoCard(
                  context,
                  shopDetails.name,
                  shopDetails.address,
                  shopDetails.distanceKm,
                  shopDetails.avgRating,
                  shopDetails.lat,
                  shopDetails.long,
                ),

                // Tab bar
                _buildTabBar(context),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAboutTab(shopDetails),
                      _buildServicesTab(shopDetails),
                    ],
                  ),
                ),

                // Bottom button
                _buildBottomButton(
                  context,
                  shopDetails.name,
                  shopDetails.address,
                ),
              ],
            ),
          );
        },
        loading: () => SafeArea(
          child: Column(
            children: [
              // Header placeholder while loading
              Container(
                height: 220.h,
                width: double.infinity,
                color: AppColors.greyDark,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor(context),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryColor(context),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading shop details...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textGrey(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Failed to load shop details',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  ErrorMessageMapper.getDisplayMessage(error),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey(context),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(shopDetailsNotifierProvider.notifier).refresh();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor(context),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoHeader(BuildContext context, List photos, bool isOpen) {
    if (photos.isEmpty) {
      return _buildSinglePhoto(context, null, isOpen);
    }

    if (photos.length == 1) {
      return _buildSinglePhoto(context, photos.first.url, isOpen);
    }

    // Multiple photos - show carousel
    return Stack(
      children: [
        SizedBox(
          height: 220.h,
          child: PageView.builder(
            controller: _photoPageController,
            onPageChanged: (index) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(photos[index].url),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        // Photo indicator dots - Enhanced visibility
        Positioned(
          bottom: 16.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  photos.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPhotoIndex == index ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPhotoIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Open/Closed badge
        Positioned(
          top: 16.h,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isOpen ? const Color(0xFF4CAF50) : Colors.red,
              borderRadius: BorderRadius.circular(4.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              isOpen ? 'Open' : 'Closed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Back button
        Positioned(
          top: 16.h,
          left: 16.w,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSinglePhoto(
    BuildContext context,
    String? imageUrl,
    bool isOpen,
  ) {
    return Stack(
      children: [
        Container(
          height: 220.h,
          width: double.infinity,
          decoration: BoxDecoration(
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: imageUrl == null ? AppColors.greyDark : null,
          ),
          child: imageUrl == null
              ? Center(
                  child: Icon(
                    Icons.store,
                    size: 64.sp,
                    color: AppColors.greyLight,
                  ),
                )
              : null,
        ),

        // Open/Closed badge
        Positioned(
          top: 16.h,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isOpen ? const Color(0xFF4CAF50) : Colors.red,
              borderRadius: BorderRadius.circular(4.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              isOpen ? 'Open' : 'Closed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Back button
        Positioned(
          top: 16.h,
          left: 16.w,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMap(BuildContext context, double lat, double long) async {
    // Try native map app first
    final nativeUri = Uri.parse('geo:$lat,$long?q=$lat,$long');
    // Fallback to web browser
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$long',
    );

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
      }
    }
  }

  Widget _buildBarberInfoCard(
    BuildContext context,
    String name,
    String address,
    double? distanceKm,
    double? avgRating,
    double? latitude,
    double? longitude,
  ) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Name
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inverseScaffoldBackground(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),

                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.sp,
                      color: AppColors.textGrey(context),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        distanceKm != null
                            ? '$address (${distanceKm.toStringAsFixed(1)} km)'
                            : address,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textGrey(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // Rating
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16.sp,
                      color: avgRating != null
                          ? AppColors.primaryColor(context)
                          : AppColors.greyLight,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      avgRating != null
                          ? avgRating.toStringAsFixed(1)
                          : 'Not rated',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textGrey(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Maps button — only show if coordinates are available
          if (latitude != null && longitude != null)
            InkWell(
              onTap: () => _openMap(context, latitude, longitude),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryColor(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.primaryColor(context),
                      size: 24.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Maps',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textGrey(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryColor(context),
        unselectedLabelColor: AppColors.textGrey(context),
        indicatorColor: AppColors.primaryColor(context),
        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Services'),
        ],
      ),
    );
  }

  Widget _buildAboutTab(shopDetails) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (shopDetails.description != null &&
              shopDetails.description!.isNotEmpty) ...[
            _buildSectionTitle('Description'),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.greyDark.withValues(alpha: 0.3)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                shopDetails.description!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textGrey(context),
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Opening Hours
          if (shopDetails.workingDays.isNotEmpty) ...[
            _buildSectionTitle('Opening Hours'),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textGrey(context).withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: shopDetails.workingDays.asMap().entries.map<Widget>((
                  entry,
                ) {
                  final index = entry.key;
                  final day = entry.value;
                  final dayName = _getDayNameFromInt(day.dayOfWeek);
                  final isLast = index == shopDetails.workingDays.length - 1;

                  final isOpen = day.opensAt != null && day.closesAt != null;

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: AppColors.textGrey(
                                  context,
                                ).withValues(alpha: 0.2),
                              ),
                            ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16.sp,
                              color: AppColors.primaryColor(context),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.inverseScaffoldBackground(
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16.sp,
                              color: AppColors.textGrey(context),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              isOpen
                                  ? '${_formatTime(day.opensAt!)} - ${_formatTime(day.closesAt!)}'
                                  : 'Closed',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isOpen
                                    ? AppColors.textGrey(context)
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Reviews - Only show if there are reviews
          if (shopDetails.reviews.isNotEmpty) ...[
            _buildSectionTitle('Reviews (${shopDetails.reviews.length})'),
            SizedBox(height: 12.h),
            ...shopDetails.reviews.map((review) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildReviewCard(
                  name: review.reviewerName,
                  rating: review.rating,
                  review: review.comment ?? '',
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.inverseScaffoldBackground(context),
      ),
    );
  }

  String _formatTime(String time) {
    // Convert "10:00:00" to "10:00 AM"
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  String _getDayNameFromInt(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dayOfWeek - 1];
  }

  Widget _buildReviewCard({
    required String name,
    required double rating,
    required String review,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.greyDark.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textGrey(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primaryColor(
                  context,
                ).withValues(alpha: 0.2),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor(context),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inverseScaffoldBackground(context),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.floor()
                              ? Icons.star
                              : (index < rating
                                    ? Icons.star_half
                                    : Icons.star_border),
                          size: 16.sp,
                          color: AppColors.primaryColor(context),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              review,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textGrey(context),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesTab(shopDetails) {
    if (shopDetails.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.content_cut, size: 64.sp, color: AppColors.greyLight),
            SizedBox(height: 16.h),
            Text(
              'No services available',
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
      padding: EdgeInsets.all(20.w),
      itemCount: shopDetails.services.length,
      itemBuilder: (context, index) {
        final service = shopDetails.services[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(service) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryColor(context).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor(context).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Service icon
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor(context),
                  AppColors.primaryColor(context).withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.content_cut, color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 16.w),

          // Service details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inverseScaffoldBackground(context),
                  ),
                ),
                if (service.description != null &&
                    service.description!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    service.description!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textGrey(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: AppColors.textGrey(context),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${service.durationMinutes} min',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textGrey(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Price
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${service.price.toStringAsFixed(0)} SAR',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    String shopName,
    String shopAddress,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppButton(
        text: 'Book Now',
        onTap: () {
          final shopDetailsAsync = ref.read(shopDetailsNotifierProvider);
          shopDetailsAsync.whenData((shopDetails) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(
                  shopId: widget.shopId,
                  shopName: shopDetails.name,
                  services: shopDetails.services,
                  workingDays: shopDetails.workingDays,
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
