import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/utils/error_message_mapper.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import '../../logic/my_booking_providers.dart';

class RatingReviewScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String shopId;
  final String shopName;
  final String? shopImage;
  final double? shopRating;
  final int? shopRatingCount;
  final String? shopAddress;
  final double? distanceKm;

  const RatingReviewScreen({
    super.key,
    required this.bookingId,
    required this.shopId,
    required this.shopName,
    this.shopImage,
    this.shopRating,
    this.shopRatingCount,
    this.shopAddress,
    this.distanceKm,
  });

  @override
  ConsumerState<RatingReviewScreen> createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends ConsumerState<RatingReviewScreen> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  final List<String> _tags = [
    'Overall good',
    'Good service',
    'Satisfying',
    'Comfortable',
    'Recommended',
    'Cheap',
    'Perfect results',
    'Accurate estimate',
  ];

  @override
  void initState() {
    super.initState();
    _reviewController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final reviewText = _reviewController.text.trim();

    await ref
        .read(addReviewProvider.notifier)
        .submitReview(
          bookingId: widget.bookingId,
          shopId: widget.shopId,
          rating: _selectedRating,
          review: reviewText,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor(context);
    final appBarForeground = AppColors.scaffoldBackground(context);
    final topInfoColor = AppColors.scaffoldBackground(context);

    // Listen to state changes for side effects
    ref.listen(addReviewProvider, (previous, next) {
      next.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review submitted successfully!')),
            );
            Navigator.pop(context, true);
          }
        },
        error: (error, stack) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ErrorMessageMapper.getDisplayMessage(error))),
            );
          }
        },
        loading: () {},
      );
    });

    final isLoading = ref.watch(addReviewProvider).isLoading;
    final isButtonEnabled =
        _selectedRating > 0 &&
        _reviewController.text.trim().isNotEmpty &&
        !isLoading;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarForeground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rating & Review',
          style: TextStyle(color: appBarForeground),
        ),
      ),
      body: Column(
        children: [
          // Top section with barber info
          Container(
            padding: EdgeInsets.all(16.0.w),
            color: primaryColor,
            child: Container(
              padding: EdgeInsets.all(12.0.w),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  // Barber image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      width: 70.w,
                      height: 70.h,
                      color: Colors.grey[300],
                      child: widget.shopImage != null
                          ? Image.network(
                              widget.shopImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.person, color: Colors.grey),
                            )
                          : Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Barber info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.shopName,
                          style: TextStyle(
                            color: topInfoColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: topInfoColor,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                _locationWithDistance(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: topInfoColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        if (widget.shopRating != null)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${widget.shopRating!.toStringAsFixed(1)} (${widget.shopRatingCount ?? 0})',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12.sp,
                                ),
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

          // Main content area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.black : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating section
                    Text(
                      'Rating',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Star rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRating = index + 1;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 8.0.w),
                              child: Icon(
                                Icons.star,
                                color: index < _selectedRating
                                    ? primaryColor
                                    : Colors.grey[400],
                                size: 40.sp,
                              ),
                            ),
                          );
                        }),
                        SizedBox(width: 8.w),
                        Text(
                          '(${_selectedRating.toStringAsFixed(1)})',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Review section
                    Text(
                      'Review',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Review text field
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        ),
                      ),
                      child: TextField(
                        controller: _reviewController,
                        maxLines: 4,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Share your experience...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          // Allow submit button to update visually immediately
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Tags
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _tags.map((tag) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_reviewController.text.isNotEmpty) {
                                _reviewController.text += ' $tag';
                              } else {
                                _reviewController.text = tag;
                              }
                              // Set cursor to end
                              _reviewController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _reviewController.text.length,
                                    ),
                                  );
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[900]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Submit button
          Container(
            padding: EdgeInsets.all(24.0.w),
            color: isDark ? AppColors.black : Colors.white,
            child: AppButton(
              text: isLoading ? 'Sending...' : 'Send',
              onTap: isButtonEnabled ? _submitReview : null,
            ),
          ),
        ],
      ),
    );
  }

  String _locationWithDistance() {
    final address = widget.shopAddress?.trim();
    final hasAddress = address != null && address.isNotEmpty;
    final hasDistance = widget.distanceKm != null;

    if (hasAddress && hasDistance) {
      return '$address (${widget.distanceKm!.toStringAsFixed(1)} km)';
    }
    if (hasAddress) {
      return address;
    }
    if (hasDistance) {
      return '${widget.distanceKm!.toStringAsFixed(1)} km';
    }

    return 'Location unavailable';
  }
}
