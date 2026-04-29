import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/utils/error_message_mapper.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/core/widgets/app_phone_field.dart';
import 'package:my_barber/features/register/data/api/register_constants.dart';
import 'package:my_barber/features/register/data/models/register_model.dart';
import 'package:my_barber/features/register/logic/register_notifier.dart';
import 'package:my_barber/features/register/presentation/widgets/have_account.dart';
import 'package:my_barber/features/register/presentation/widgets/register_form.dart';
import 'package:my_barber/features/register/presentation/widgets/register_header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _isRegistering = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Track selected country for phone number
  Country? selectedCountry;

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(registerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          // Show error in a dialog for better visibility
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
                    'Registration Failed',
                    style: TextStyle(
                      color: AppColors.inverseScaffoldBackground(context),
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              content: Text(
                ErrorMessageMapper.getDisplayMessage(error),
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
        },
        data: (_) {
          if (next.isLoading) {
            return; // Don't react to loading -> data transition immediately if previous was null
          }
        },
      );

      // Show success dialog and navigate to OTP screen
      if (_isRegistering && !next.isLoading && !next.hasError && previous?.isLoading == true) {
        _isRegistering = false; // Reset to prevent crosstalk
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissal during navigation
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.scaffoldBackground(context),
            title: Text(
              'Registration Successful',
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
                  RegisterConstants.checkEmailAnimation,
                  width: 150.w,
                  height: 150.h,
                  repeat: false,
                ),
                SizedBox(height: 16.h),
                Text(
                  RegisterErrorMessages.emailSent,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGrey(context),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor(context),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).then((_) {
          if (context.mounted) {
            context.go(
              AppRoutes.registerOTP,
              extra: emailController.text.trim(),
            );
          }
        });
      }
    });

    final state = ref.watch(registerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 16.h,
                  children: [
                    const RegisterHeader(),

                    RegisterForm(
                      nameController: nameController,
                      emailController: emailController,
                      phoneController: phoneController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      onCountryChanged: (country) {
                        setState(() {
                          selectedCountry = country;
                        });
                      },
                    ),

                    isLoading
                        ? const CircularProgressIndicator()
                        : AppButton(
                            text: 'Register',
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                            _isRegistering = true;
                            // Get clean phone number with country code
                            final cleanPhoneNumber = selectedCountry != null
                                    ? PhoneNumberUtils.getCleanPhoneNumber(
                                        phoneController,
                                        selectedCountry!,
                                      )
                                    : phoneController.text.trim();

                                ref
                                    .read(registerProvider.notifier)
                                    .register(
                                      registerModel: RegisterModel(
                                        email: emailController.text.trim(),
                                        password: passwordController.text,
                                        phoneNumber: cleanPhoneNumber,
                                        fullName: nameController.text.trim(),
                                      ),
                                    );
                              }
                            },
                          ),

                    const HaveAccount(),
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
