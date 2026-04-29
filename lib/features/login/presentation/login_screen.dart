import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/assets/app_assets.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/core/widgets/app_form_field.dart';
import 'package:my_barber/features/login/logic/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isObscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    ref.listen(loginProvider, (previous, next) {
      if (next.errorMessage != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Success is handled by the router watching auth state
      // But we can add a fallback or success message if needed
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).brightness,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            // 1. Graphics widget (Background + Graphic Image)
            Widget buildGraphics() {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: isLandscape ? Alignment.center : Alignment.topCenter,
                      child: SizedBox(
                        width: double.infinity,
                        height: isLandscape ? double.infinity : constraints.maxHeight * 0.4,
                        child: SvgPicture.asset(
                          AppAssets.backgroundSvgImage,
                          fit: BoxFit.fill,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.white
                                : AppColors.black,
                            BlendMode.xor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: isLandscape ? Alignment.center : Alignment.topCenter,
                      child: Padding(
                        padding: isLandscape ? EdgeInsets.all(24.w) : EdgeInsets.only(top: 24.h),
                        child: Image.asset(
                          'assets/login/login.png',
                          width: isLandscape ? constraints.maxWidth * 0.4 : constraints.maxWidth * 0.8,
                          fit: BoxFit.contain, // Safely fit without squishing
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // 2. Form Widget
            Widget buildForm() {
              return Container(
                height: isLandscape ? double.infinity : null, // Fill height for landscape row
                constraints: isLandscape
                    ? null
                    : BoxConstraints(
                        minHeight: constraints.maxHeight * 0.65,
                        maxHeight: constraints.maxHeight * 0.75,
                      ),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground(context),
                  borderRadius: isLandscape
                      ? BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          bottomLeft: Radius.circular(24.r),
                        )
                      : BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.r,
                      offset: Offset(0, -5.h),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    top: 24.w,
                    bottom: 24.w + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        spacing: 16.h,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                'Please enter your login information below to access your account',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.textGrey(context),
                                ),
                              ),
                            ],
                          ),

                          AppTextFormField(
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email,
                            isPassword: false,
                            labelText: 'Email',
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),

                          AppTextFormField(
                            hintText: 'Enter your password',
                            prefixIcon: Icons.key_rounded,
                            isPassword: true,
                            labelText: 'Password',
                            controller: passwordController,
                            obscureText: isObscure,
                            keyboardType: TextInputType.visiblePassword,
                            onShowPassword: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  context.push(AppRoutes.forgetPassword),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          loginState.isLoading
                              ? const CircularProgressIndicator()
                              : AppButton(
                                  text: 'Login',
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      ref
                                          .read(loginProvider.notifier)
                                          .login(
                                            emailController.text.trim(),
                                            passwordController.text.trim(),
                                          );
                                    }
                                  },
                                ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.register),
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            if (isLandscape) {
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: buildGraphics(),
                  ),
                  Expanded(
                    flex: 1,
                    child: SafeArea(top: false, bottom: false, left: false, child: buildForm()),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                buildGraphics(),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: buildForm(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
