import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/widgets/app_button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _emailController = TextEditingController(text: 'Joesamanta@gmail.com');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account details saved successfully.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.inverseScaffoldBackground(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account',
          style: TextStyle(
            color: AppColors.inverseScaffoldBackground(context),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // Profile Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.textGrey(context),
                    child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, size: 16.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // User Name
            Center(
              child: Text(
                'Mohamed Abdo',
                style: TextStyle(
                  color: AppColors.inverseScaffoldBackground(context),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            // Email Field
            _buildTextField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              suffixIcon: Icons.check,
            ),
            SizedBox(height: 16.h),
            // Password Field
            _buildTextField(
              label: 'Password',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              obscureText: _obscurePassword,
              onSuffixTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            SizedBox(height: 32.h),
            AppButton(text: 'Save', onTap: _saveAccount),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.inverseScaffoldBackground(context),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.tffBorderColor(context),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(
              color: AppColors.inverseScaffoldBackground(context),
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                prefixIcon,
                color: AppColors.inverseScaffoldBackground(context),
                size: 20.sp,
              ),
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        suffixIcon,
                        color: AppColors.inverseScaffoldBackground(context),
                        size: 20.sp,
                      ),
                      onPressed: onSuffixTap,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
