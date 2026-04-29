import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class BookingCard extends StatelessWidget {
  final String barberName;
  final String service;
  final String date;
  final String time;
  final String status;
  final bool isUpcoming;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;
  final VoidCallback? onBookAgain;

  const BookingCard({
    super.key,
    required this.barberName,
    required this.service,
    required this.date,
    required this.time,
    required this.status,
    required this.isUpcoming,
    this.onCancel,
    this.onViewDetails,
    this.onBookAgain,
  });

  @override
  Widget build(BuildContext context) {
    final handleCancel =
        onCancel ??
        () => _showNotAvailable(context, 'Cancel action is not available yet.');
    final handleViewDetails =
        onViewDetails ??
        () => _showNotAvailable(context, 'Details are not available yet.');
    final handleBookAgain =
        onBookAgain ??
        () => _showNotAvailable(context, 'Book again is not available yet.');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.greyDark,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 60.h,
                width: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground(context),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.store,
                  size: 28.sp,
                  color: AppColors.greyLight,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barberName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      service,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: status == 'Confirmed'
                      ? AppColors.primaryColor(context).withValues(alpha: 0.2)
                      : AppColors.scaffoldBackground(context),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: status == 'Confirmed'
                        ? AppColors.primaryColor(context)
                        : AppColors.greyLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: AppColors.scaffoldBackground(context), height: 1.h),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16.sp,
                color: AppColors.greyLight,
              ),
              SizedBox(width: 8.w),
              Text(
                date,
                style: TextStyle(fontSize: 14.sp, color: AppColors.greyLight),
              ),
              SizedBox(width: 24.w),
              Icon(Icons.access_time, size: 16.sp, color: AppColors.greyLight),
              SizedBox(width: 8.w),
              Text(
                time,
                style: TextStyle(fontSize: 14.sp, color: AppColors.greyLight),
              ),
            ],
          ),
          if (isUpcoming) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: handleCancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primaryColor(context),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: handleViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!isUpcoming) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleBookAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Book Again',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showNotAvailable(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
