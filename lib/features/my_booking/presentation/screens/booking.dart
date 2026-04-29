import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/features/my_booking/presentation/widgets/booking_upcoming.dart';
import 'package:my_barber/features/my_booking/presentation/widgets/booking_header.dart';
import 'package:my_barber/features/my_booking/presentation/widgets/booking_history.dart';
import 'package:my_barber/features/my_booking/presentation/widgets/booking_segment_selector.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            spacing: 16.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              BookingHeader(),

              BookingSegmentSelector(
                selectedIndex: _selectedIndex,
                onSegmentChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),

              SizedBox(height: 4.h),

              Expanded(
                child: _selectedIndex == 0
                    ? UpcomingBookingsList()
                    : HistoryBookingsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
