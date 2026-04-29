import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Register here ',
          style: TextStyle(
            fontSize: 28.sp,
            color: AppColors.primaryColor(context),
            fontWeight: FontWeight.bold,
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
