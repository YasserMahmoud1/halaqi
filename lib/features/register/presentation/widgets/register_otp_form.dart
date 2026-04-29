import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:pinput/pinput.dart';

class RegisterOtpForm extends StatelessWidget {
  final TextEditingController pinController;
  final FocusNode pinFocusNode;
  final Function(String) onCompleted;

  const RegisterOtpForm({
    super.key,
    required this.pinController,
    required this.pinFocusNode,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: pinController,
      focusNode: pinFocusNode,
      length: 6,
      defaultPinTheme: PinTheme(
        width: 60.w,
        height: 60.h,
        textStyle: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300, width: 2.w),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 60.w,
        height: 60.h,
        textStyle: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primaryColor(context),
            width: 2.w,
          ),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 60.w,
        height: 60.h,
        textStyle: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primaryColor(context),
            width: 2.w,
          ),
        ),
      ),
      onCompleted: onCompleted,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      cursor: Container(
        width: 2.w,
        height: 30.h,
        color: AppColors.primaryColor(context),
      ),
    );
  }
}
