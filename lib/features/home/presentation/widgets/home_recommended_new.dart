import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/features/home/data/models/home_data_model.dart';

/// Pure presentation component - receives data from parent
class HomeMostRecommendedBarbersNew extends StatefulWidget {
  final List<ShopItemModel> recommendedShops;

  const HomeMostRecommendedBarbersNew({
    super.key,
    required this.recommendedShops,
  });

  @override
  State<HomeMostRecommendedBarbersNew> createState() =>
      _HomeMostRecommendedBarbersNewState();
}

class _HomeMostRecommendedBarbersNewState
    extends State<HomeMostRecommendedBarbersNew> {
  int _currentPage = 0;
  PageController? _pageController;
  bool _wasTablet = false;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;
    if (_pageController == null || _wasTablet != isTablet) {
      // Recreate the controller to apply new viewport fraction without memory leak
      final oldController = _pageController;
      Future.microtask(() => oldController?.dispose());
      _pageController = PageController(viewportFraction: isTablet ? 0.4 : 0.85);
      _wasTablet = isTablet;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Most Recommended",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.push('/home/view-all-shops/recommended');
                },
                child: Text(
                  "See All >",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        if (widget.recommendedShops.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: const Text("No recommended shops found."),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 240.h,
                child: PageView.builder(
                  padEnds: !isTablet,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: widget.recommendedShops.length,
                  itemBuilder: (context, index) {
                    final shopItem = widget.recommendedShops[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            '${AppRoutes.barberDetails}/${shopItem.shopId}',
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 150.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.greyDark,
                                    borderRadius: BorderRadius.circular(12.r),
                                    image: shopItem.coverImage != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              shopItem.coverImage!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: shopItem.coverImage == null
                                      ? const Center(
                                          child: Icon(
                                            Icons.store,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  top: 12.h,
                                  left: 12.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_pin,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "${shopItem.distanceKm?.toStringAsFixed(1) ?? 'N/A'} km",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12.h,
                                  right: 12.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: AppColors.primaryColor(
                                            context,
                                          ),
                                          size: 14.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          shopItem.avgRating?.toStringAsFixed(
                                                1,
                                              ) ??
                                              "Not Rated",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              shopItem.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
              if (widget.recommendedShops.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.recommendedShops.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == index ? 24.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primaryColor(context)
                            : AppColors.greyDark,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
