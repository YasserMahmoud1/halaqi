import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/features/home/logic/home_providers.dart';

class HomeMostRecommendedBarbers extends ConsumerStatefulWidget {
  const HomeMostRecommendedBarbers({super.key});

  @override
  ConsumerState<HomeMostRecommendedBarbers> createState() =>
      _HomeMostRecommendedBarbersState();
}

class _HomeMostRecommendedBarbersState
    extends ConsumerState<HomeMostRecommendedBarbers> {
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendedShopsAsync = ref.watch(recommendedShopsProvider);

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
                onPressed: () {},
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
        recommendedShopsAsync.when(
          data: (shops) {
            if (shops.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: const Text("No recommended shops found."),
              );
            }
            return Column(
              children: [
                SizedBox(
                  height: 200.h,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.barberDetails, extra: shop);
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
                                      image: shop.imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                shop.imageUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: shop.imageUrl == null
                                        ? const Center(
                                            child: Icon(
                                              Icons.store,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          )
                                        : null,
                                  ),
                                  if (shop.distance != null)
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
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
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
                                              "${shop.distance?.toStringAsFixed(1) ?? '--'} km",
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
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
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
                                            shop.rating.toStringAsFixed(1),
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
                                shop.name,
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
                if (shops.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      shops.length,
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
            );
          },
          loading: () => SizedBox(
            height: 200.h,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }
}
