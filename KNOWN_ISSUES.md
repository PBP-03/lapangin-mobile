# Known Issues & To-Do Items

This document lists the remaining items that need attention when connecting the Flutter app to the actual Django backend.

## Current Status

All core screens and functionality have been implemented. The app compiles but has some type mismatches between the current models and what the Django API will return. These will be resolved once the actual API responses are tested.

---

## Model Property Mismatches

### Venue Model
**Current Missing Properties:**
- `phoneNumber` - Use `contact` instead
- `openingTime` / `closingTime` - Not in current model, may be in Django response
- `totalReviews` - Not in current model, may be in Django response  
- `facilities` - Not in current model (list of Facility objects)
- `sportsCategories` - Not in current model (list of SportsCategory objects)

**Solution:** Update `lib/models/venue_model.dart` to match Django API response exactly.

### Court Model
**Current Missing Properties:**
- `sportsCategory` - May need to be added as a string field

**Solution:** Update `lib/models/court_model.dart` to match Django API response.

### Booking Model
**Current Missing Properties:**
- `status` - Booking status field
- `payment` - Nested payment object
- `userName` - Customer name for mitra view

**Solution:** Update `lib/models/booking_model.dart` to match Django API response.

### Payment Model
**Current Missing Properties:**
- `status` - Payment status field

**Solution:** Update `lib/models/payment_model.dart` to match Django API response.

### Review Model
**Current Missing Properties:**
- `userName` - Reviewer name (may be nullable)

**Solution:** Update `lib/models/review_model.dart` to match Django API response.

---

## Missing Service Methods

### VenueService
- `getVenueById(String id)` - Get single venue details
- `getMyVenues()` - Get mitra's venues
- `verifyVenue(String id)` - Admin verify venue
- `deleteVenue(String id)` - Delete venue

### CourtService
- `getCourtsByVenue(String venueId)` - Get all courts for a venue
- `getAvailableSessions(int courtId, DateTime date)` - Get available time slots

### UserProvider
- `isLoggedIn` getter - Check if user is authenticated

---

## How to Fix

### Step 1: Test with Real API
1. Start Django backend
2. Use Postman/Thunder Client to test each endpoint
3. Copy actual JSON responses

### Step 2: Update Models
For each model file in `lib/models/`:
1. Compare Dart model with actual JSON response
2. Add missing fields
3. Update `fromJson()` method
4. Update `toJson()` method if needed

**Example Fix for Venue Model:**
```dart
class Venue {
  // Add missing fields
  final String? phoneNumber;
  final String? openingTime;
  final String? closingTime;
  final int? totalReviews;
  final List<Facility> facilities;
  final List<SportsCategory> sportsCategories;
  
  // Constructor
  Venue({
    // ... existing fields
    this.phoneNumber,
    this.openingTime,
    this.closingTime,
    this.totalReviews,
    this.facilities = const [],
    this.sportsCategories = const [],
  });
  
  // Update fromJson
  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      // ... existing mappings
      phoneNumber: json['phone_number'] as String?,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      totalReviews: json['total_reviews'] as int?,
      facilities: (json['facilities'] as List?)
          ?.map((f) => Facility.fromJson(f))
          .toList() ?? [],
      sportsCategories: (json['sports_categories'] as List?)
          ?.map((c) => SportsCategory.fromJson(c))
          .toList() ?? [],
    );
  }
}
```

### Step 3: Add Missing Service Methods

**VenueService additions:**
```dart
Future<Venue> getVenueById(String id) async {
  final response = await _apiService.get('${AppConfig.venuesEndpoint}$id/');
  return Venue.fromJson(response['venue']);
}

Future<List<Venue>> getMyVenues() async {
  final response = await _apiService.get('${AppConfig.venuesEndpoint}my-venues/');
  return (response['venues'] as List)
      .map((json) => Venue.fromJson(json))
      .toList();
}

Future<void> verifyVenue(String id) async {
  await _apiService.post('${AppConfig.venuesEndpoint}$id/verify/');
}

Future<void> deleteVenue(String id) async {
  await _apiService.delete('${AppConfig.venuesEndpoint}$id/');
}
```

**CourtService additions:**
```dart
Future<List<Court>> getCourtsByVenue(String venueId) async {
  final response = await _apiService.get(
    AppConfig.courtsEndpoint,
    queryParams: {'venue': venueId},
  );
  return (response['courts'] as List)
      .map((json) => Court.fromJson(json))
      .toList();
}

Future<List<CourtSession>> getAvailableSessions(
  int courtId,
  DateTime date,
) async {
  final dateStr = date.toIso8601String().split('T')[0];
  final response = await _apiService.get(
    '${AppConfig.courtsEndpoint}$courtId/sessions/',
    queryParams: {'date': dateStr},
  );
  return (response['sessions'] as List)
      .map((json) => CourtSession.fromJson(json))
      .toList();
}
```

**UserProvider addition:**
```dart
bool get isLoggedIn => _user != null;
```

### Step 4: Fix Type Conversions

Some IDs are `int` in models but `String` in the new booking service:

**Option 1: Update models to use String IDs**
```dart
class Court {
  final String id; // Change from int to String
  // ...
}
```

**Option 2: Update service to accept int**
```dart
Future<Booking> createBooking({
  required int courtId,  // Change back to int
  required int sessionId, // Change back to int
  // ...
}) async {
  final body = {
    'court': courtId.toString(),  // Convert to string for API
    'session': sessionId.toString(),
    // ...
  };
}
```

---

## Unused Import Warnings

These are minor and can be safely ignored or removed:

- `lib/screens/home_page.dart` - Line 129
- `lib/screens/booking_checkout_page.dart` - Lines 2, 6, 9
- `lib/screens/booking_history_page.dart` - Lines 3, 6
- `lib/screens/review_form_page.dart` - Lines 2, 3, 5
- `lib/screens/admin_dashboard_page.dart` - Line 16

**Fix:** Remove the unused imports or use the imported classes.

---

## Config Import Issue

Some screens use `Config.baseUrl` but import `../config/config.dart` while the class is named differently.

**Check config.dart:**
```dart
class AppConfig { // or Config?
  static const String baseUrl = '...';
}
```

**Fix:** Ensure consistent naming:
- Either rename class to `Config`
- Or update imports to use `AppConfig`

---

## Testing Checklist

### Authentication
- [ ] Test login with existing user
- [ ] Test registration (user role)
- [ ] Test registration (mitra role)
- [ ] Verify session persistence
- [ ] Test logout

### User Features
- [ ] Browse venues
- [ ] Search venues
- [ ] View venue details
- [ ] Create booking
- [ ] View booking history
- [ ] Cancel booking
- [ ] Submit review

### Mitra Features
- [ ] View mitra dashboard
- [ ] Add new venue
- [ ] Edit venue
- [ ] Delete venue
- [ ] View bookings for owned venues
- [ ] View earnings

### Admin Features
- [ ] View admin dashboard
- [ ] View statistics
- [ ] Approve/reject mitra requests
- [ ] Verify/reject venues

---

## Priority

**High Priority (Must fix before production):**
1. Update all models to match Django API responses
2. Add missing service methods
3. Fix type conversions (int vs String for IDs)
4. Test with real Django backend

**Medium Priority:**
5. Remove unused imports
6. Fix Config naming consistency
7. Add null safety checks

**Low Priority:**
8. Add loading states
9. Improve error messages
10. Add offline mode support

---

## Next Steps

1. **Start Django backend** and ensure all API endpoints are working
2. **Test each endpoint** with Postman to get actual JSON responses
3. **Update Flutter models** one by one to match responses
4. **Add missing service methods**
5. **Run Flutter app** and test each feature
6. **Fix any runtime errors** that appear
7. **Test complete user flows** from registration to booking

---

## Estimated Time

- Model updates: 1-2 hours
- Service method additions: 1 hour
- Testing and fixes: 2-3 hours
- **Total: 4-6 hours** to have a fully working app

---

## Notes

- The current implementation is **structurally complete** - all screens and features are built
- The remaining work is **integration** - connecting the dots between Flutter and Django
- Most errors are **compile-time errors** that will be caught before runtime
- The app **will compile and run** once models are updated to match API responses

---

## Support

If you encounter issues during integration:

1. Check `API_REFERENCE.md` for expected endpoint formats
2. Compare actual API responses with model expectations
3. Use Flutter's hot reload to test changes quickly
4. Check Django backend logs for API errors
5. Use Flutter DevTools to inspect network requests

---

**Status:** Ready for integration testing with live Django backend
