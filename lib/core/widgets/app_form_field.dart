import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.isPassword,
    required this.labelText,
    required this.controller,
    this.onShowPassword,
    this.obscureText = false,
    this.keyboardType = TextInputType.emailAddress,
    this.validator,
  });
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final String labelText;
  final TextEditingController controller;
  final VoidCallback? onShowPassword;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(labelText, style: TextStyle(fontSize: 14.sp)),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.primaryColor(context),
              selectionColor: AppColors.primaryColor(
                context,
              ).withValues(alpha: 0.3),
              selectionHandleColor: AppColors.primaryColor(context),
            ),
          ),
          child: TextFormField(
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            controller: controller,
            cursorColor: AppColors.primaryColor(context),
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: Icon(
                prefixIcon,
                color: AppColors.primaryColor(context),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: onShowPassword,
                      icon: obscureText
                          ? Icon(
                              Icons.visibility_off,
                              color: AppColors.textGrey(context),
                            )
                          : Icon(
                              Icons.visibility,
                              color: AppColors.textGrey(context),
                            ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: AppColors.primaryColor(context),
                  width: 2.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: AppColors.primaryColor(context),
                  width: 2.w,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: AppColors.tffBorderColor(context),
                ),
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.textGrey(context),
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
