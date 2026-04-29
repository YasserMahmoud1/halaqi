import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class RegisterOtpHeader extends StatelessWidget {
  const RegisterOtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Authentication',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor(context),
          ),
        ),
        Text(
          "Please enter the authentication code that we have sent to your email",
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
