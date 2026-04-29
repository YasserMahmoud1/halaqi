import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/route_names.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class HomeSearch extends StatelessWidget {
  const HomeSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(RouteName.search.value);
        },
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.greyDark
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              Icon(
                Icons.search,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.greyLight
                    : Colors.grey.shade500,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Search for barber shops',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.greyLight
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
