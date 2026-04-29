import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/features/home/logic/home_providers.dart';

class HomeNearestBarbers extends ConsumerWidget {
  const HomeNearestBarbers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyShopsAsync = ref.watch(nearbyShopsProvider);

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
          SizedBox(height: 16.h),
          nearbyShopsAsync.when(
            data: (shops) {
              if (shops.isEmpty) {
                return const Text("No nearby shops found.");
              }
              return Column(
                children: shops.take(3).map((shop) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: GestureDetector(
                      onTap: () {
                        context.push(AppRoutes.barberDetails, extra: shop);
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
                                image: shop.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(shop.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: shop.imageUrl == null
                                  ? const Icon(Icons.store, color: Colors.white)
                                  : null,
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    shop.name,
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
                                          shop.distance != null
                                              ? "${shop.distance?.toStringAsFixed(1) ?? 'N/A'} km - ${shop.address}"
                                              : shop.address,
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
                                        shop.rating.toStringAsFixed(1),
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}
