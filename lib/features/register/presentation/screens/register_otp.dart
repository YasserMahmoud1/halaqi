import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/utils/error_message_mapper.dart';
import 'package:my_barber/core/utils/validators.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/features/register/data/api/register_constants.dart';
import 'package:my_barber/features/register/logic/register_notifier.dart';
import 'package:my_barber/features/register/presentation/widgets/register_otp_form.dart';
import 'package:my_barber/features/register/presentation/widgets/register_otp_header.dart';
import 'package:my_barber/features/register/presentation/widgets/register_otp_resend.dart';

class RegisterOtp extends ConsumerStatefulWidget {
  const RegisterOtp({super.key});

  @override
  ConsumerState<RegisterOtp> createState() => _RegisterOtpState();
}

class _RegisterOtpState extends ConsumerState<RegisterOtp> {
  final TextEditingController pinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();

  @override
  void dispose() {
    pinController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }

  /// Verifies the OTP and handles navigation
  void _verifyOtp(String email) {
    final otp = pinController.text.trim();

    // Validate OTP before submitting
    final validationError = Validators.validateOTP(
      otp,
      length: RegisterConstants.otpLength,
    );

    if (validationError != null) {
      _showErrorDialog(validationError);
      return;
    }

    ref
        .read(registerProvider.notifier)
        .verifyOtp(email: email, token: otp)
        .then((_) {
          if (context.mounted && !ref.read(registerProvider).hasError) {
            _showSuccessDialogAndNavigate();
          }
        });
  }

  /// Shows error dialog with custom message
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground(context),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8.w),
            Text(
              'Verification Failed',
              style: TextStyle(
                color: AppColors.inverseScaffoldBackground(context),
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textGrey(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor(context),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows success dialog and navigates to home
  void _showSuccessDialogAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground(context),
        title: Text(
          'Success!',
          style: TextStyle(
            color: AppColors.inverseScaffoldBackground(context),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              RegisterConstants.successAnimation,
              width: 150.w,
              height: 150.h,
              repeat: false,
            ),
            SizedBox(height: 16.h),
            Text(
              RegisterErrorMessages.accountCreated,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textGrey(context),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (context.mounted) {
                context.go(AppRoutes.home, extra: 'register_success');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor(context),
            ),
            child: Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve email passed as extra
    final email = GoRouterState.of(context).extra as String?;

    // Redirect if email is missing (should not happen in normal flow)
    if (email == null) {
      // Defer navigation to next frame to avoid build phase errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.register);
      });
      return const SizedBox.shrink();
    }

    // Listen to provider state changes
    ref.listen(registerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          _showErrorDialog(ErrorMessageMapper.getDisplayMessage(error));
        },
      );
    });

    final otpState = ref.watch(registerProvider);
    final isLoading = otpState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryColor(context)),
      ),
      backgroundColor: AppColors.scaffoldBackground(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 80.h),
            child: SingleChildScrollView(
              child: Column(
                spacing: 32.h,
                children: [
                  const RegisterOtpHeader(),

                  RegisterOtpForm(
                    pinController: pinController,
                    pinFocusNode: pinFocusNode,
                    onCompleted: (pin) => _verifyOtp(email),
                  ),

                  // Loading indicator or Submit button
                  SizedBox(
                    height: 48.h,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(text: 'Verify', onTap: () => _verifyOtp(email)),
                  ),

                  RegisterOtpResend(email: email),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
