import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirm.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (newPassword.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }

    if (newPassword != confirm) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) {
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
          'Change Password',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a new password for your account.',
              style: TextStyle(
                color: AppColors.textGrey(context),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            // New Password Field
            _buildTextField(
              label: 'New Password',
              controller: _newPasswordController,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureNew
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              obscureText: _obscureNew,
              onSuffixTap: () => setState(() => _obscureNew = !_obscureNew),
            ),
            SizedBox(height: 16.h),
            // Confirm Password Field
            _buildTextField(
              label: 'Confirm New Password',
              controller: _confirmPasswordController,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              obscureText: _obscureConfirm,
              onSuffixTap: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            SizedBox(height: 32.h),
            // Save Button
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor(context),
                    ),
                  )
                : AppButton(text: 'Save', onTap: _savePassword),
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
