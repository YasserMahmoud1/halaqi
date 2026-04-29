import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingHeader extends StatelessWidget {
  const BookingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'My Bookings',
      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
    );
  }
}