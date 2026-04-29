import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, this.onTap, required this.text});
  final VoidCallback? onTap;
  final String text;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primaryColor(context)
              : Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.scaffoldBackground(context),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
