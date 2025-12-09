# Django-Flutter Data Model Mapping

This document shows how Django models in the backend map to Flutter models in the mobile app.

## User Model

### Django (`app/users/models.py`)
```python
class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    role = models.CharField(max_length=10, choices=USER_ROLES, default='user')
    phone_number = models.CharField(max_length=20)
    address = models.TextField()
    profile_picture = models.URLField(max_length=500)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### Flutter (`lib/models/user_model.dart`)
```dart
class User {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? phoneNumber;
  final String? address;
  final String? profilePicture;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## Venue Model

### Django (`app/venues/models.py`)
```python
class Venue(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    name = models.CharField(max_length=255)
    owner = models.ForeignKey(User, on_delete=models.CASCADE)
    address = models.TextField()
    location_url = models.URLField(max_length=500)
    contact = models.CharField(max_length=20)
    description = models.TextField()
    number_of_courts = models.PositiveIntegerField(default=1)
    verification_status = models.CharField(max_length=10)
    verified_by = models.ForeignKey(User, on_delete=models.SET_NULL)
    verification_date = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### Flutter (`lib/models/venue_model.dart`)
```dart
class Venue {
  final String id;
  final String name;
  final String ownerId;
  final String address;
  final String? locationUrl;
  final String? contact;
  final String? description;
  final int numberOfCourts;
  final String verificationStatus;
  final String? verifiedBy;
  final DateTime? verificationDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final double? averageRating;
  final List<String> categories;
  final double? averagePrice;
}
```

## Court Model

### Django (`app/courts/models.py`)
```python
class Court(models.Model):
    id = models.AutoField(primary_key=True)
    venue = models.ForeignKey(Venue, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    category = models.ForeignKey(SportsCategory, on_delete=models.CASCADE)
    price_per_hour = models.DecimalField(max_digits=10, decimal_places=2)
    is_active = models.BooleanField(default=True)
    maintenance_notes = models.TextField()
    description = models.TextField()
```

### Flutter (`lib/models/court_model.dart`)
```dart
class Court {
  final int id;
  final String venueId;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final double pricePerHour;
  final bool isActive;
  final String? maintenanceNotes;
  final String? description;
  final List<String> images;
}
```

## Booking Model

### Django (`app/bookings/models.py`)
```python
class Booking(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    court = models.ForeignKey(Court, on_delete=models.CASCADE)
    session = models.ForeignKey(CourtSession, on_delete=models.SET_NULL)
    booking_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    duration_hours = models.DecimalField(max_digits=4, decimal_places=2)
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    booking_status = models.CharField(max_length=10)
    payment_status = models.CharField(max_length=10)
    notes = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### Flutter (`lib/models/booking_model.dart`)
```dart
class Booking {
  final String id;
  final String userId;
  final int courtId;
  final int? sessionId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double durationHours;
  final double totalPrice;
  final String bookingStatus;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? venueName;
  final String? courtName;
}
```

## API Endpoint Mapping

### Authentication
| Django Endpoint | Flutter Service | Method |
|----------------|-----------------|--------|
| `/api/login/` | `AuthService.login()` | POST |
| `/api/register/` | `AuthService.register()` | POST |
| `/api/logout/` | `AuthService.logout()` | POST |
| `/api/user-status/` | `AuthService.getUserStatus()` | GET |
| `/api/profile/` | `AuthService.getProfile()` | GET |
| `/api/profile/` | `AuthService.updateProfile()` | PUT |

### Venues
| Django Endpoint | Flutter Service | Method |
|----------------|-----------------|--------|
| `/api/public/venues/` | `VenueService.getVenues()` | GET |
| `/api/public/venues/{id}/` | `VenueService.getVenueDetail()` | GET |
| `/api/sports-categories/` | `VenueService.getSportsCategories()` | GET |
| `/api/venues/` | `VenueService.createVenue()` | POST |
| `/api/venues/{id}/` | `VenueService.updateVenue()` | PUT |
| `/api/venues/{id}/` | `VenueService.deleteVenue()` | DELETE |

### Courts
| Django Endpoint | Flutter Service | Method |
|----------------|-----------------|--------|
| `/api/courts/` | `CourtService.getCourts()` | GET |
| `/api/courts/{id}/` | `CourtService.getCourtDetail()` | GET |
| `/api/courts/{id}/sessions/` | `CourtService.getCourtSessions()` | GET |
| `/api/courts/` | `CourtService.createCourt()` | POST |
| `/api/courts/{id}/` | `CourtService.updateCourt()` | PUT |
| `/api/courts/{id}/` | `CourtService.deleteCourt()` | DELETE |

### Bookings
| Django Endpoint | Flutter Service | Method |
|----------------|-----------------|--------|
| `/api/bookings/` | `BookingService.getMyBookings()` | GET |
| `/api/bookings/` | `BookingService.createBooking()` | POST |
| `/api/bookings/{id}/` | `BookingService.getBookingDetail()` | GET |
| `/api/bookings/{id}/` | `BookingService.updateBookingStatus()` | PATCH |
| `/api/bookings/{id}/` | `BookingService.cancelBooking()` | PATCH |

### Reviews
| Django Endpoint | Flutter Service | Method |
|----------------|-----------------|--------|
| `/api/venues/{id}/reviews/` | `ReviewService.getVenueReviews()` | GET |
| `/api/reviews/` | `ReviewService.createReview()` | POST |
| `/api/reviews/{id}/` | `ReviewService.updateReview()` | PUT |
| `/api/reviews/{id}/` | `ReviewService.deleteReview()` | DELETE |

## Data Type Conversions

### UUID (Django) → String (Flutter)
```python
# Django
id = models.UUIDField(primary_key=True, default=uuid.uuid4)
```
```dart
// Flutter
final String id;
```

### DateTimeField (Django) → DateTime (Flutter)
```python
# Django
created_at = models.DateTimeField(auto_now_add=True)
```
```dart
// Flutter
final DateTime createdAt;

// Parsing
DateTime.parse(json['created_at'])
```

### DateField (Django) → DateTime (Flutter)
```python
# Django
booking_date = models.DateField()
```
```dart
// Flutter
final DateTime bookingDate;

// To send to backend
bookingDate.toIso8601String().split('T')[0]  // "2024-11-26"
```

### TimeField (Django) → String (Flutter)
```python
# Django
start_time = models.TimeField()  # Stored as "14:30:00"
```
```dart
// Flutter
final String startTime;  // Keep as string "14:30:00"
```

### DecimalField (Django) → double (Flutter)
```python
# Django
price_per_hour = models.DecimalField(max_digits=10, decimal_places=2)
```
```dart
// Flutter
final double pricePerHour;

// Parsing
(json['price_per_hour'] as num).toDouble()
```

### ForeignKey (Django) → String/int (Flutter)
```python
# Django
owner = models.ForeignKey(User, on_delete=models.CASCADE)
```
```dart
// Flutter
final String ownerId;  // Just store the ID
```

## JSON Serialization Examples

### Django to Flutter (Parsing JSON)
```dart
// Django sends:
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Lapangan Futsal ABC",
  "created_at": "2024-11-26T10:30:00Z"
}

// Flutter parses:
Venue.fromJson(Map<String, dynamic> json) {
  return Venue(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
```

### Flutter to Django (Sending JSON)
```dart
// Flutter sends:
venue.toJson() {
  return {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
  };
}

// Django receives:
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Lapangan Futsal ABC",
  "created_at": "2024-11-26T10:30:00.000Z"
}
```

## Special Cases

### Nullable Fields
```python
# Django - nullable field
contact = models.CharField(max_length=20, blank=True, null=True)
```
```dart
// Flutter - nullable field
final String? contact;

// Safe parsing
contact: json['contact'] as String?,
```

### Choice Fields (Enums)
```python
# Django
BOOKING_STATUS = [
    ('pending', 'Pending'),
    ('confirmed', 'Confirmed'),
    ('cancelled', 'Cancelled'),
]
booking_status = models.CharField(max_length=10, choices=BOOKING_STATUS)
```
```dart
// Flutter - keep as string with helper properties
final String bookingStatus;

bool get isPending => bookingStatus == 'pending';
bool get isConfirmed => bookingStatus == 'confirmed';
bool get isCancelled => bookingStatus == 'cancelled';
```

### Many-to-Many Relationships
```python
# Django
facilities = models.ManyToManyField(Facility)
```
```dart
// Flutter - represented as list in API response
final List<int> facilityIds;  // Just the IDs

// Or if full objects are included
final List<Facility> facilities;
```

## Authentication & Session Management

### Django Session Cookie
```python
# Django creates session on login
request.session['user_id'] = user.id
```

### Flutter Cookie Storage
```dart
// Flutter stores and sends cookie automatically
final prefs = await SharedPreferences.getInstance();
await prefs.setString('session_cookie', cookie);

// Included in all requests
headers['Cookie'] = _sessionCookie;
```

## Best Practices

1. **Always handle null values** - Use `?` for nullable fields
2. **Parse numbers carefully** - Use `as num` then `.toDouble()` or `.toInt()`
3. **Store UUIDs as strings** - Don't try to use UUID objects
4. **Keep time as strings** - Don't parse TimeField to DateTime
5. **Use factory constructors** - For `fromJson()` methods
6. **Add helper properties** - Like `isVerified`, `fullName`, etc.
7. **Handle errors gracefully** - Use try-catch in fromJson
8. **Document data types** - Add comments for complex fields

## Debugging Tips

### Check API Response
```dart
try {
  final response = await _apiService.get('/api/venues/');
  print(json.encode(response));  // See exact JSON structure
} catch (e) {
  print('Error: $e');
}
```

### Check Sent Data
```dart
final body = {
  'username': username,
  'password': password,
};
print('Sending: ${json.encode(body)}');
final response = await _apiService.post('/api/login/', body: body);
```

### Test in Django Shell
```python
from app.venues.models import Venue
from django.core import serializers

venue = Venue.objects.first()
print(serializers.serialize('json', [venue]))
```

This shows exactly what JSON Django produces!
