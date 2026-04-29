import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class HaveAccount extends StatelessWidget {
  const HaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(fontSize: 16.sp),
        ),
        TextButton(
          onPressed: () {
            context.go(AppRoutes.login);
          },
          child: Text(
            "Login",
            style: TextStyle(
              color: AppColors.primaryColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}
