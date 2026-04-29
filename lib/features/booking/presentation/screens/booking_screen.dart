import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/core/utils/error_message_mapper.dart';
import 'package:my_barber/features/barber_details/data/models/barber_details_response/barber_details_model.dart';
import 'package:my_barber/features/booking/logic/booking_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/time_slot_model.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String shopName;
  final List<ShopService> services;
  final List<WorkingDay> workingDays;

  const BookingScreen({
    super.key,
    required this.shopId,
    required this.shopName,
    required this.services,
    required this.workingDays,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate;
  final List<String> _selectedServiceIds = [];
  TimeSlot? _selectedTimeSlot;

  bool _isDateSelectable(DateTime currentDate, DateTime today) {
    if (currentDate.isBefore(today)) return false;

    final isToday =
        currentDate.year == today.year &&
        currentDate.month == today.month &&
        currentDate.day == today.day;

    if (!isToday) return true;

    return _isTodayStillBookable();
  }

  bool _isTodayStillBookable() {
    final now = DateTime.now();

    final todayHours = widget.workingDays
        .where((day) => day.dayOfWeek == now.weekday)
        .toList();

    if (todayHours.isEmpty) return false;

    final todaySchedule = todayHours.first;
    if (todaySchedule.closesAt == null) return false;

    try {
      final closeParts = todaySchedule.closesAt!.split(':');
      final closeHour = int.parse(closeParts[0]);
      final closeMinute = int.parse(closeParts[1]);

      final currentMinutes = now.hour * 60 + now.minute;
      final closeMinutes = closeHour * 60 + closeMinute;

      return currentMinutes < closeMinutes;
    } catch (_) {
      return false;
    }
  }

  bool _isSlotInPast(TimeSlot slot) {
    if (_selectedDate == null) return false;

    final now = DateTime.now();
    final selectedDay = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    if (selectedDay.isAfter(today)) return false;
    if (selectedDay.isBefore(today)) return true;

    try {
      final startParts = slot.startTime.split(':');
      final slotStart = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      return !slotStart.isAfter(now);
    } catch (_) {
      return false;
    }
  }

  bool _isSelectedSlotInPast() {
    if (_selectedTimeSlot == null) return false;
    return _isSlotInPast(_selectedTimeSlot!);
  }

  @override
  void initState() {
    super.initState();
    // Clear any stale slots data from previous sessions
    Future.microtask(
      () => ref.read(bookingSlotsNotifierProvider.notifier).clearSlots(),
    );

    // Initialize with current month
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  // Fetch slots when date and services are selected
  void _fetchAvailableSlots() {
    if (_selectedDate == null || _selectedServiceIds.isEmpty) {
      // Clear slots if prerequisites not met
      ref.read(bookingSlotsNotifierProvider.notifier).clearSlots();
      setState(() {
        _selectedTimeSlot = null;
      });
      return;
    }

    final dateString =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    ref
        .read(bookingSlotsNotifierProvider.notifier)
        .fetchSlots(
          shopId: widget.shopId,
          serviceIds: _selectedServiceIds,
          date: dateString,
        );

    // Clear selected time when fetching new slots
    setState(() {
      _selectedTimeSlot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(bookingSlotsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.scaffoldBackground(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Appointment',
          style: TextStyle(
            color: AppColors.scaffoldBackground(context),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Calendar Section
                      Container(
                        color: AppColors.primaryColor(context),
                        padding: EdgeInsets.all(16.w),
                        child: Column(children: [_buildCalendar()]),
                      ),

                      // Bottom Section with Services and Time
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground(context),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.r),
                            topRight: Radius.circular(24.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 24.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'Choose Service',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.inverseScaffoldBackground(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildServicesList(),
                            SizedBox(height: 24.h),

                            // Available Time Section
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'Available Time',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.inverseScaffoldBackground(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildTimeSlots(slotsAsync),
                            SizedBox(height: 24.h),
                            _buildPaymentSummary(),
                            SizedBox(height: 100.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        // Month/Year Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.scaffoldBackground(context),
              ),
              onPressed: () {
                final previousMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
                // Don't allow going to past months
                if (previousMonth.year > today.year ||
                    (previousMonth.year == today.year &&
                        previousMonth.month >= today.month)) {
                  setState(() {
                    _selectedMonth = previousMonth;
                  });
                }
              },
            ),
            Text(
              '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
              style: TextStyle(
                color: AppColors.scaffoldBackground(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: AppColors.scaffoldBackground(context),
              ),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map<Widget>(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.scaffoldBackground(
                        context,
                      ).withValues(alpha: 0.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 12.h),

        // Calendar Grid
        _buildCalendarGrid(today),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime today) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday % 7;
    final isTablet = MediaQuery.sizeOf(context).width > 600;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: isTablet ? 1.5 : 1.0,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: startWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startWeekday) {
          return const SizedBox.shrink();
        }

        final day = index - startWeekday + 1;
        final currentDate = DateTime(
          _selectedMonth.year,
          _selectedMonth.month,
          day,
        );
        final isSelectable = _isDateSelectable(currentDate, today);
        final isDisabled = !isSelectable;
        final isSelected =
            _selectedDate != null &&
            _selectedDate!.year == currentDate.year &&
            _selectedDate!.month == currentDate.month &&
            _selectedDate!.day == currentDate.day;
        final isToday =
            currentDate.year == today.year &&
            currentDate.month == today.month &&
            currentDate.day == today.day;

        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    _selectedDate = currentDate;
                  });
                  _fetchAvailableSlots();
                },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.scaffoldBackground(context)
                  : isToday
                  ? AppColors.scaffoldBackground(context).withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: isToday && !isSelected
                  ? Border.all(
                      color: AppColors.scaffoldBackground(
                        context,
                      ).withValues(alpha: 0.5),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isDisabled
                      ? AppColors.scaffoldBackground(
                          context,
                        ).withValues(alpha: 0.3)
                      : isSelected
                      ? AppColors.primaryColor(context)
                      : AppColors.scaffoldBackground(context),
                  fontSize: 14.sp,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildServicesList() {
    if (widget.services.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text(
          'No services available',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textGrey(context)),
        ),
      );
    }

    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: widget.services.length,
        itemBuilder: (context, index) {
          final service = widget.services[index];
          final isSelected = _selectedServiceIds.contains(service.id);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedServiceIds.remove(service.id);
                } else {
                  _selectedServiceIds.add(service.id);
                }
              });
              _fetchAvailableSlots();
            },
            child: Container(
              width: 140.w,
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor(context).withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor(context)
                      : AppColors.textGrey(context).withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor(
                        context,
                      ).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.content_cut,
                      color: AppColors.primaryColor(context),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    service.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: AppColors.inverseScaffoldBackground(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${service.durationMinutes ?? 0} min • ${(service.price ?? 0).toStringAsFixed(0)} SAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots(AsyncValue slotsAsync) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: slotsAsync.when(
        data: (slots) {
          if (slots.isEmpty) {
            if (_selectedDate == null || _selectedServiceIds.isEmpty) {
              return Text(
                'Please select a date and service(s) first',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textGrey(context),
                ),
              );
            }
            return Text(
              'No available time slots for the selected date and services',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textGrey(context),
              ),
            );
          }

          return Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: slots.map<Widget>((slot) {
              final formattedStart = _formatTime(slot.startTime);
              final formattedEnd = _formatTime(slot.endTime);
              final timeDisplay = '$formattedStart - $formattedEnd';
              final isSelected = _selectedTimeSlot?.startTime == slot.startTime;
              final isPastSlot = _isSlotInPast(slot);

              return GestureDetector(
                onTap: isPastSlot
                    ? null
                    : () {
                        setState(() {
                          _selectedTimeSlot = slot;
                        });
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor(context)
                        : isPastSlot
                        ? AppColors.textGrey(context).withValues(alpha: 0.08)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor(context)
                          : isPastSlot
                          ? AppColors.textGrey(context).withValues(alpha: 0.2)
                          : AppColors.textGrey(context).withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    timeDisplay,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isPastSlot
                          ? AppColors.textGrey(context)
                          : AppColors.inverseScaffoldBackground(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => Center(
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor(context),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Loading available time slots...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (error, stack) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'Failed to load time slots',
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
            ),
            TextButton(
              onPressed: _fetchAvailableSlots,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    if (_selectedServiceIds.isEmpty) {
      return const SizedBox.shrink();
    }

    int totalDuration = 0;
    double total = 0;
    final selectedServices = widget.services
        .where((service) => _selectedServiceIds.contains(service.id))
        .toList();

    for (var service in selectedServices) {
      total += service.price ?? 0;
      totalDuration += service.durationMinutes ?? 0;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground(context),
        border: Border.all(
          color: AppColors.textGrey(context).withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.inverseScaffoldBackground(context),
            ),
          ),
          SizedBox(height: 12.h),
          ...selectedServices.map<Widget>((service) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${service.name} (${service.durationMinutes ?? 0} min)',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textGrey(context),
                      ),
                    ),
                  ),
                  Text(
                    '${(service.price ?? 0).toStringAsFixed(2)} SAR',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.inverseScaffoldBackground(context),
                    ),
                  ),
                ],
              ),
            );
          }),
          Divider(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Duration',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey(context),
                ),
              ),
              Text(
                '$totalDuration mins',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inverseScaffoldBackground(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inverseScaffoldBackground(context),
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} SAR',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final isEnabled =
        _selectedServiceIds.isNotEmpty &&
        _selectedTimeSlot != null &&
        _selectedDate != null &&
        !_isSelectedSlotInPast();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppButton(
        text: 'Confirm Booking',
        onTap: isEnabled ? _confirmBooking : null,
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null || _selectedTimeSlot == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final userId = user.id;

      // Parse Date + Time
      final startParts = _selectedTimeSlot!.startTime.split(':');
      final fromDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      final endParts = _selectedTimeSlot!.endTime.split(':');
      final toDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      // Calculate Total
      double totalCost = 0;
      for (var service in widget.services) {
        if (_selectedServiceIds.contains(service.id)) {
          totalCost += service.price ?? 0;
        }
      }

      final repository = ref.read(bookingRepositoryProvider);
      final result = await repository.createBooking(
        userId: userId,
        shopId: widget.shopId,
        fromDateTime: fromDateTime,
        toDateTime: toDateTime,
        serviceIds: _selectedServiceIds,
        totalCost: totalCost,
      );

      // Hide loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        if (result.isSuccess) {
          // Success
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
          Navigator.pop(context); // Go back to shop details
        } else {
          // Error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error?.message ?? 'Booking failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading if exception
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (mounted) {
        final errorMessage = ErrorMessageMapper.getDisplayMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      var hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;

      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }
}
