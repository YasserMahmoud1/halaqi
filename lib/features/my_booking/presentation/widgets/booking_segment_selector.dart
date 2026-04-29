import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class BookingSegmentSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSegmentChanged;

  const BookingSegmentSelector({
    super.key,
    required this.selectedIndex,
    required this.onSegmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.greyDark.withValues(alpha: 0.5)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(50.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSegmentChanged(0),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? AppColors.primaryColor(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Center(
                  child: Text(
                    'Upcoming',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: selectedIndex == 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selectedIndex == 0
                          ? AppColors.scaffoldBackground(context)
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSegmentChanged(1),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? AppColors.primaryColor(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Center(
                  child: Text(
                    'History',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: selectedIndex == 1
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selectedIndex == 1
                          ? AppColors.scaffoldBackground(context)
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}