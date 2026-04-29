import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/features/home/data/models/home_data_model.dart';

/// Pure presentation component - receives data from parent
class HomeNearestBarbersNew extends StatelessWidget {
  final List<ShopItemModel> nearestShops;

  const HomeNearestBarbersNew({super.key, required this.nearestShops});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nearest Barbers",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.push('/home/view-all-shops/nearest');
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
          SizedBox(height: 16.h),
          if (nearestShops.isEmpty)
            const Text("No nearby shops found.")
          else
            Column(
              children: nearestShops.take(3).map((shopItem) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: GestureDetector(
                    onTap: () {
                      context.push(
                        '${AppRoutes.barberDetails}/${shopItem.shopId}',
                      );
                    },
                    child: SizedBox(
                      height: 100.h,
                      child: Row(
                        children: [
                          Container(
                            height: 100.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              color: AppColors.greyDark,
                              borderRadius: BorderRadius.circular(12.r),
                              image: shopItem.coverImage != null
                                  ? DecorationImage(
                                      image: NetworkImage(shopItem.coverImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: shopItem.coverImage == null
                                ? const Icon(Icons.store, color: Colors.white)
                                : null,
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  shopItem.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      color: AppColors.primaryColor(context),
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        "${shopItem.distanceKm?.toStringAsFixed(1) ?? 'N/A'} km",
                                        style: TextStyle(fontSize: 14.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.primaryColor(context),
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      shopItem.avgRating?.toStringAsFixed(1) ??
                                          "Not Rated",
                                      style: TextStyle(fontSize: 14.sp),
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
              }).toList(),
            ),
        ],
      ),
    );
  }
}
