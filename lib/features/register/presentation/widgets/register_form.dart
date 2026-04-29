import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/utils/validators.dart';
import 'package:my_barber/core/widgets/app_form_field.dart';
import 'package:my_barber/core/widgets/app_phone_field.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final void Function(Country)? onCountryChanged;

  const RegisterForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.onCountryChanged,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool passwordIsObscure = true;
  bool confirmPasswordIsObscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.h,
      children: [
        AppTextFormField(
          hintText: "Enter your name",
          prefixIcon: Icons.person,
          isPassword: false,
          labelText: "Name",
          controller: widget.nameController,
          keyboardType: TextInputType.name,
          validator: Validators.validateName,
        ),
        AppTextFormField(
          hintText: "Enter your email",
          prefixIcon: Icons.email,
          isPassword: false,
          labelText: "Email",
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        AppPhoneField(
          controller: widget.phoneController,
          labelText: "Phone Number",
          hintText: "Enter your phone number",
          validator: Validators.validatePhone,
          onCountryChanged: widget.onCountryChanged,
        ),
        AppTextFormField(
          hintText: "Enter your password",
          prefixIcon: Icons.key,
          isPassword: true,
          labelText: "Password",
          controller: widget.passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: passwordIsObscure,
          onShowPassword: () {
            setState(() {
              passwordIsObscure = !passwordIsObscure;
            });
          },
          validator: Validators.validatePassword,
        ),
        AppTextFormField(
          hintText: "Enter your password confirmation",
          prefixIcon: Icons.key,
          isPassword: true,
          labelText: "Password Confirmation",
          controller: widget.confirmPasswordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: confirmPasswordIsObscure,
          onShowPassword: () {
            setState(() {
              confirmPasswordIsObscure = !confirmPasswordIsObscure;
            });
          },
          validator: (value) => Validators.validatePasswordConfirmation(
            value,
            widget.passwordController.text,
          ),
        ),
      ],
    );
  }
}
