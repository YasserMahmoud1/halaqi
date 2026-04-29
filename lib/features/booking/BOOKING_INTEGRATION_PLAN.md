# Booking Feature Integration Plan

## Objective
Integrate real shop data (services, working days) into the booking screen and fetch available time slots from the `get_available_slots` RPC.

## Files to Create/Modify

### 1. Create Slots Models
**File**: `lib/features/booking/data/models/time_slot_model.dart`
```dart
// Models for the get_available_slots RPC response
@JsonSerializable()
class AvailableSlotsResponse {
  final List<TimeSlot> slots;
  @JsonKey(name: 'slot_duration')
  final int slotDuration;
}

@JsonSerializable()
class TimeSlot {
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
}
```

### 2. Create Slots API Service
**File**: `lib/features/booking/data/api/booking_api_service.dart`
- Method: `getAvailableSlots(shopId, serviceIds, date)`
- Calls RPC: `get_available_slots`
- Parameters:
  - `p_shop_id`: UUID
  - `p_services_id`: List<String>
  - `p_date`: String (YYYY-MM-DD)

### 3. Create Slots Repository
**File**: `lib/features/booking/data/repository/booking_repository.dart`
- Wraps API service with error handling
- Returns `Result<AvailableSlotsResponse>`

### 4. Create Slots Notifier
**File**: `lib/features/booking/logic/slots_notifier.dart`
- `BookingSlotsNotifier extends AsyncNotifier<List<TimeSlot>>`
- Method: `fetchSlots(shopId, serviceIds, date)`
- Manages loading/error states

### 5. Update Booking Screen
**File**: `lib/features/booking/presentation/screens/booking_screen.dart`

**Changes Required**:
1. **Constructor Parameters**:
   ```dart
   BookingScreen({
     required String shopId,
     required String shopName,
     required List<ShopService> services,  // From ShopDetails
     required List<WorkingDay> workingDays,  // From ShopDetails
   })
   ```

2. **Calendar Logic**:
   - Disable past dates
   - Only show months starting from current month
   - Gray out and disable tap on past dates

3. **Service Selection**:
   - Use real services data passed from ShopDetails
   - Track selected service IDs (not names)

4. **Slot Fetching**:
   - When date AND services are selected → fetch slots
   - Use `bookingSlotsNotifier`
   - Show loading while fetching
   - Display fetched slots instead of mock data

5. **Validation**:
   - Prevent navigating to past months
   - Only enable "Deal booking" when:
     - Date selected (not in past)
     - At least one service selected
     - Time slot selected

### 6. Update Navigation from Barber Details
**File**: `lib/features/barber_details/presentation/screens/barber_details.dart`

**Change**:
```dart
// OLD
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingScreen(
      barberName: shopName,
      barberLocation: shopAddress,
    ),
  ),
);

// NEW
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingScreen(
      shopId: widget.shopId,
      shopName: shopDetails.name,
      services: shopDetails.services,
      workingDays: shopDetails.workingDays,
    ),
  ),
);
```

## User Flow

```
1. User on Barber Details Screen
   ↓
2. Taps "Book Now"
   ↓
3. Navigate to Booking Screen with:
   - shopId
   - shopName
   - services list
   - workingDays list
   ↓
4. Booking Screen shows:
   - Calendar (past dates disabled)
   - Real services from shop
   ↓
5. User selects date (only future dates allowed)
   ↓
6. User selects one or more services
   ↓
7. System calls get_available_slots RPC with:
   - p_shop_id = shopId
   - p_services_id = [selected service IDs]
   - p_date = selected date (YYYY-MM-DD)
   ↓
8. Display available time slots
   ↓
9. User selects time slot
   ↓
10. "Deal booking" button enabled
   ↓
11. User confirms booking
```

## Calendar Logic - Disable Past Dates

```dart
Widget _buildCalendarGrid() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // ...existing code...
  
  itemBuilder: (context, index) {
    if (index < startWeekday) {
      return SizedBox.shrink();
    }
    
    final day = index - startWeekday + 1;
    final currentDate = DateTime(_selectedYear, _selectedMonth, day);
    final isPast = currentDate.isBefore(today);
    
    return GestureDetector(
      onTap: isPast ? null : () {
        setState(() {
          _selectedDay = day;
          // Trigger slot fetching
          _fetchAvailableSlots();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isPast
              ? Colors.grey.withOpacity(0.3)  // Gray out past dates
              : (isSelected ? Colors.white : Colors.transparent),
        ),
        child: Text(
          day.toString(),
          style: TextStyle(
            color: isPast
                ? Colors.grey  // Gray text for past dates
                : (isSelected ? primaryColor : Colors.white),
          ),
        ),
      ),
    );
  },
}
```

## Slot Fetching Logic

```dart
void _fetchAvailableSlots() {
  if (_selectedDay == null || _selectedServiceIds.isEmpty) {
    return; // Don't fetch if date or services not selected
  }
  
  final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay!);
  final dateString = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
  
  ref.read(bookingSlotsNotifierProvider.notifier).fetchSlots(
    shopId: widget.shopId,
    serviceIds: _selectedServiceIds,
    date: dateString,
  );
}
```

## Implementation Order

1. ✅ Create time slot models
2. ✅ Create booking API service
3. ✅ Create booking repository
4. ✅ Create booking slots notifier
5. ✅ Create providers
6. ✅ Update booking screen constructor
7. ✅ Implement calendar past date logic
8. ✅ Implement service selection with IDs
9. ✅ Implement slot fetching trigger
10. ✅ Display fetched slots
11. ✅ Update navigation from barber details

## Next Steps

Would you like me to:
1. Implement all the files step by step?
2. Start with the data layer (models, API, repository)?
3. Focus on specific parts first?

Let me know and I'll proceed with the implementation!
