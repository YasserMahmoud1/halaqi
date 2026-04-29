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

class ForgetPassword extends ConsumerStatefulWidget {
  const ForgetPassword({super.key});

  @override
  ConsumerState<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends ConsumerState<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    await ref.read(forgetPasswordProvider.notifier).sendResetEmail(email);

    // On success navigate to OTP screen, passing the email
    if (mounted && ref.read(forgetPasswordProvider).isSuccess) {
      ref.read(forgetPasswordProvider.notifier).clearState();
      context.push(AppRoutes.forgetPasswordOTP, extra: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgetPasswordProvider);

    // Show error snackbar whenever an error appears
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
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor(context),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your email and we\'ll send you a reset code.',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 32.h),
                    AppTextFormField(
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email,
                      isPassword: false,
                      labelText: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    SizedBox(height: 32.h),
                    state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(text: 'Send Reset Code', onTap: _submit),
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
