import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/utils/validators.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/core/widgets/app_form_field.dart';
import 'package:my_barber/features/login/logic/forget_password_provider.dart';

class ResetPassword extends ConsumerStatefulWidget {
  const ResetPassword({super.key});

  @override
  ConsumerState<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends ConsumerState<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(forgetPasswordProvider.notifier)
        .updatePassword(_passwordController.text);

    if (mounted && ref.read(forgetPasswordProvider).isSuccess) {
      ref.read(forgetPasswordProvider.notifier).clearState();
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Please log in.'),
        ),
      );
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgetPasswordProvider);

    ref.listen(forgetPasswordProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryColor(context)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 80.h),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set New Password',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor(context),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your identity has been verified.\nPlease enter your new password.',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 32.h),
                    AppTextFormField(
                      hintText: 'Enter new password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      labelText: 'New Password',
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscurePassword,
                      onShowPassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: Validators.validatePassword,
                    ),
                    SizedBox(height: 16.h),
                    AppTextFormField(
                      hintText: 'Confirm new password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      labelText: 'Confirm Password',
                      controller: _confirmController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscureConfirm,
                      onShowPassword: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (value) => Validators.validatePasswordConfirmation(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(text: 'Update Password', onTap: _submit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
