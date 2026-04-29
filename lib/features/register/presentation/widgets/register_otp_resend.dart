import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/features/register/data/api/register_constants.dart';
import 'package:my_barber/features/register/logic/register_notifier.dart';

class RegisterOtpResend extends ConsumerStatefulWidget {
  final String email;
  const RegisterOtpResend({super.key, required this.email});

  @override
  ConsumerState<RegisterOtpResend> createState() => _RegisterOtpResendState();
}

class _RegisterOtpResendState extends ConsumerState<RegisterOtpResend> {
  Timer? _timer;
  int _start = RegisterConstants.otpResendCooldown;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _start = RegisterConstants.otpResendCooldown;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleResend() async {
    await ref.read(registerProvider.notifier).resendOtp(email: widget.email);

    if (mounted && !ref.read(registerProvider).hasError) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(RegisterErrorMessages.otpResent),
          duration: const Duration(seconds: 3),
        ),
      );
      // Restart timer
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_canResend)
          Text(
            "Resend code in 00:${_start.toString().padLeft(2, '0')}",
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        TextButton(
          onPressed: _canResend ? _handleResend : null,
          child: Text(
            "Have not received code?",
            style: TextStyle(
              color: _canResend ? AppColors.primaryColor(context) : Colors.grey,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}
