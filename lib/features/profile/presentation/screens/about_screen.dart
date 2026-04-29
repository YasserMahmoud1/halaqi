import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/widgets/app_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  // App Logo
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.content_cut,
                      size: 60.sp,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // App Name
                  Text(
                    'Halaqi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // About Halaqi Section
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground(context),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Halaqi',
                          style: TextStyle(
                            color: AppColors.inverseScaffoldBackground(context),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '"Halaqi: The Best Solution for Online Barber Booking!" Want a more practical and effortless way to find haircut services? Halaqi is the best solution for you! Halaqi is an online barber booking application that makes it easy for you to book and enjoy quality haircut services easily and quickly.',
                          style: TextStyle(
                            color: AppColors.textGrey(context),
                            fontSize: 14.sp,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // TODO: Uncomment when app store rating is implemented
                        /*
                        Text(
                          'Rating App',
                          style: TextStyle(
                            color: AppColors.inverseScaffoldBackground(context),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        InkWell(
                          onTap: () {
                            TODO: Navigate to app store
                          },
                          child: Row(
                            children: [
                              Text(
                                "Let's rate this App",
                                style: TextStyle(
                                  color: AppColors.textGrey(context),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.inverseScaffoldBackground(
                                  context,
                                ),
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ),
                        */
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Back Button
          Container(
            padding: EdgeInsets.all(24.w),
            child: AppButton(text: 'Back', onTap: () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }
}
