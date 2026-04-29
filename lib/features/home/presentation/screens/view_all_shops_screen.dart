import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/features/home/data/models/home_data_model.dart';
import 'package:my_barber/features/home/logic/home_providers.dart';

enum ShopListType { recommended, nearest }

class ViewAllShopsScreen extends ConsumerWidget {
  final ShopListType listType;

  const ViewAllShopsScreen({super.key, required this.listType});

  String get _title {
    switch (listType) {
      case ShopListType.recommended:
        return 'Recommended Barbers';
      case ShopListType.nearest:
        return 'Nearest Barbers';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: homeDataAsync.when(
        data: (homeData) {
          final List<ShopItemModel> shops = listType == ShopListType.recommended
              ? homeData.recommended
              : homeData.nearest;

          if (shops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64.sp,
                    color: AppColors.greyLight,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No shops found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.greyLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(24.w),
            itemCount: shops.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final shop = shops[index];
              return _ShopListItem(shop: shop);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text('Could not load shops. Please try again.'),
        ),
      ),
    );
  }
}

class _ShopListItem extends StatelessWidget {
  final ShopItemModel shop;

  const _ShopListItem({required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('${AppRoutes.barberDetails}/${shop.shopId}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColors.greyDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
                image: shop.coverImage != null
                    ? DecorationImage(
                        image: NetworkImage(shop.coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: shop.coverImage == null
                  ? const Icon(Icons.store, color: Colors.white)
                  : null,
            ),

            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: AppColors.primaryColor(context),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            "${shop.distanceKm?.toStringAsFixed(1) ?? 'N/A'} km",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textGrey(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          shop.avgRating?.toStringAsFixed(1) ?? 'Not rated',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
