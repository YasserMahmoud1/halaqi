import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/features/login/logic/forget_password_provider.dart';
import 'package:pinput/pinput.dart';

class ForgetPasswordOtp extends ConsumerStatefulWidget {
  const ForgetPasswordOtp({super.key});

  @override
  ConsumerState<ForgetPasswordOtp> createState() => _ForgetPasswordOtpState();
}

class _ForgetPasswordOtpState extends ConsumerState<ForgetPasswordOtp> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verify(String email) async {
    final otp = _pinController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit code.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref
        .read(forgetPasswordProvider.notifier)
        .verifyOtp(email: email, token: otp);

    if (mounted && ref.read(forgetPasswordProvider).isSuccess) {
      ref.read(forgetPasswordProvider.notifier).clearState();
      // Navigate to reset-password screen; the user now has a valid session
      context.go(AppRoutes.resetPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Email is passed from the ForgetPassword screen
    final email = GoRouterState.of(context).extra as String?;

    if (email == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.forgetPassword);
      });
      return const SizedBox.shrink();
    }

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

    final state = ref.watch(forgetPasswordProvider);

    final defaultPinTheme = PinTheme(
      width: 60.w,
      height: 60.h,
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.tffBorderColor(context), width: 2),
      ),
    );

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Reset Code',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'We sent a 6-digit code to\n$email',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 32.h),
                  Center(
                    child: Pinput(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor(
                            context,
                          ).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryColor(context),
                            width: 2,
                          ),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor(
                            context,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryColor(context),
                            width: 2,
                          ),
                        ),
                      ),
                      onCompleted: (_) => _verify(email),
                      showCursor: true,
                      cursor: Container(
                        width: 2.w,
                        height: 30.h,
                        color: AppColors.primaryColor(context),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AppButton(text: 'Verify Code', onTap: () => _verify(email)),
                  SizedBox(height: 16.h),
                  Center(
                    child: TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              await ref
                                  .read(forgetPasswordProvider.notifier)
                                  .sendResetEmail(email);
                              if (!context.mounted) {
                                return;
                              }

                              if (ref.read(forgetPasswordProvider).isSuccess) {
                                ref
                                    .read(forgetPasswordProvider.notifier)
                                    .clearState();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('A new code has been sent.'),
                                  ),
                                );
                              }
                            },
                      child: Text(
                        'Resend code',
                        style: TextStyle(
                          color: AppColors.primaryColor(context),
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
