import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class HomeAds extends StatelessWidget {
  const HomeAds({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 24.w),
      child: Container(
        height: 150.h,
        decoration: BoxDecoration(
          color: AppColors.greyDark,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            "Ad Banner",
            style: TextStyle(
              fontSize: 20.sp,
              color: AppColors.greyLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}