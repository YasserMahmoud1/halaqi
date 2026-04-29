# Search Barber Shops Implementation

## Overview
This implementation adds search functionality for barber shops using the Supabase RPC `search_barber_shops`. The search includes a debounce mechanism to prevent excessive API calls while users are typing.

## What Was Implemented

### 1. Data Model (`search_result_model.dart`)
- **Location**: `lib/features/home/data/models/search_result_model.dart`
- **Purpose**: Defines the structure for search results matching the Supabase RPC response
- **Classes**:
  - `SearchResultsModel`: Container for search results
  - `SearchShopItemModel`: Individual shop item with fields:
    - `shopId`: Unique identifier for the shop
    - `name`: Shop name
    - `coverImage`: Optional cover image URL
    - `avgRating`: Optional average rating
    - `distanceKm`: Distance from user location in kilometers

### 2. API Service (`home_api_service.dart`)
- **Location**: `lib/features/home/data/api/home_api_service.dart`
- **Method Added**: `searchBarberShops(query, latitude, longitude)`
- **Purpose**: Calls the `search_barber_shops` RPC with the following parameters:
  - `p_query`: Search query (shop name)
  - `p_lad`: User latitude
  - `p_long`: User longitude

### 3. Repository (`shop_repository.dart`)
- **Location**: `lib/features/home/data/repository/shop_repository.dart`
- **Method Added**: `searchShops(query, latitude, longitude)`
- **Purpose**: Wraps the API call with proper error handling
- **Returns**: `Result<SearchResultsModel>` for type-safe error handling

### 4. Search Notifier (`search_notifier.dart`)
- **Location**: `lib/features/home/logic/search_notifier.dart`
- **Purpose**: Manages search state with debounce mechanism
- **Features**:
  - **Debounce**: 500ms delay before triggering search
  - **State Management**: Tracks loading, results, errors, and current query
  - **Auto-cleanup**: Cancels pending timers when disposed
  - **Location Integration**: Automatically uses user's current location
- **Key Methods**:
  - `search(String query)`: Initiates search with debounce
  - `clear()`: Clears search results and resets state

### 5. Provider (`home_providers.dart`)
- **Provider Added**: `searchNotifierProvider`
- **Type**: `NotifierProvider<SearchNotifier, SearchState>`
- **Purpose**: Exposes search functionality throughout the app

## How to Use

### Basic Usage
```dart
// In your widget
final searchState = ref.watch(searchNotifierProvider);

// Trigger search (with debounce)
ref.read(searchNotifierProvider.notifier).search(query);

// Clear search
ref.read(searchNotifierProvider.notifier).clear();

// Access state
searchState.isLoading // Loading indicator
searchState.results   // List of search results
searchState.error     // Error message if any
searchState.query     // Current search query
```

### Example Widget
See `lib/features/home/presentation/widgets/search_example.dart` for a complete example implementation.

### Integration in TextField
```dart
TextField(
  onChanged: (query) {
    // Called on every keystroke
    // Debounce mechanism handles the delay automatically
    ref.read(searchNotifierProvider.notifier).search(query);
  },
  // ... other properties
)
```

## Debounce Mechanism

### How It Works
1. User types in search field
2. `search()` method is called on every keystroke
3. Previous timer is cancelled
4. New 500ms timer is created
5. If user stops typing for 500ms, search is executed
6. If user continues typing, timer resets

### Benefits
- Reduces API calls significantly
- Improves app performance
- Better user experience (no lag while typing)
- Reduces server load
- Saves bandwidth

### Configuration
The debounce duration can be adjusted in `search_notifier.dart`:
```dart
static const _debounceDuration = Duration(milliseconds: 500);
```

## Architecture

### Data Flow
```
User Input (TextField)
    ↓
SearchNotifier.search() [with debounce]
    ↓
ShopRepository.searchShops()
    ↓
HomeApiService.searchBarberShops()
    ↓
Supabase RPC: search_barber_shops
    ↓
SearchResultsModel
    ↓
SearchState (updated)
    ↓
UI (automatically rebuilds)
```

### State Management
- Uses Riverpod 3.x with `Notifier` pattern
- State is immutable using `copyWith()`
- Automatic cleanup with `ref.onDispose()`

## Error Handling

The implementation includes comprehensive error handling:
- Location unavailable errors
- Database/RPC errors
- Network errors
- Unexpected errors

All errors are captured and displayed in `searchState.error`.

## Files Created/Modified

### Created
1. `lib/features/home/data/models/search_result_model.dart`
2. `lib/features/home/data/models/search_result_model.g.dart` (generated)
3. `lib/features/home/logic/search_notifier.dart`
4. `lib/features/home/presentation/widgets/search_example.dart`

### Modified
1. `lib/features/home/data/api/home_api_service.dart`
2. `lib/features/home/data/repository/shop_repository.dart`
3. `lib/features/home/logic/home_providers.dart`

## Testing Recommendations

1. **Test debounce**: Verify search only triggers after typing stops
2. **Test empty query**: Ensure results clear when query is empty
3. **Test error handling**: Simulate location unavailable scenarios
4. **Test results display**: Verify all shop data displays correctly
5. **Test clear functionality**: Ensure clear() resets state properly

## Future Enhancements

Potential improvements:
- Adjustable debounce duration
- Search history
- Recent searches caching
- Pagination for large result sets
- Filter options (by rating, distance, etc.)
- Sort options

## Dependencies

- `flutter_riverpod: ^3.0.3`
- `supabase_flutter: ^2.12.0`
- `json_annotation: ^4.9.0`
- `build_runner: ^2.4.13` (dev)
- `json_serializable: ^6.8.0` (dev)
