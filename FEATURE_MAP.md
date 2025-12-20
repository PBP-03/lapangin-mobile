# LapangIN Mobile - Feature Map

## Application Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│                      (lapangin-mobile)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS + Cookies
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Django Backend                            │
│                     (LapangIN-PBP)                          │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   SQLite/    │  │   Session    │  │   REST APIs  │     │
│  │  PostgreSQL  │  │     Auth     │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## Screen Navigation Map

```
Login Page
    │
    ├─ Register Page
    │
    └─ Home Page (Venue List)
            │
            ├─ Profile Page
            │    │
            │    ├─ Booking History
            │    ├─ Mitra Dashboard (if role=mitra)
            │    │    ├─ My Venues Tab
            │    │    │    └─ Venue Form (Add/Edit)
            │    │    ├─ Bookings Tab
            │    │    └─ Earnings Page
            │    │
            │    └─ Admin Dashboard (if role=admin)
            │         ├─ Statistics Tab
            │         ├─ Mitra Requests Tab
            │         └─ Venue Approvals Tab
            │
            └─ Venue Detail Page
                    │
                    ├─ About Tab
                    ├─ Courts Tab
                    ├─ Reviews Tab
                    │
                    └─ Booking Checkout
                            └─ Booking History
                                 └─ Review Form
```

---

## User Role Features

### 👤 Regular User
```
┌──────────────────────────┐
│    User Dashboard        │
├──────────────────────────┤
│ ✓ Browse Venues          │
│ ✓ Search & Filter        │
│ ✓ View Venue Details     │
│ ✓ Book Courts            │
│ ✓ View Booking History   │
│ ✓ Cancel Bookings        │
│ ✓ Submit Reviews         │
│ ✓ View Profile           │
└──────────────────────────┘
```

### 🏢 Mitra (Venue Owner)
```
┌──────────────────────────┐
│   Mitra Dashboard        │
├──────────────────────────┤
│ ✓ All User Features      │
│ ✓ Add Venues             │
│ ✓ Edit/Delete Venues     │
│ ✓ View My Bookings       │
│ ✓ Track Earnings         │
│ ✓ Venue Verification     │
│   Status                 │
└──────────────────────────┘
```

### 👨‍💼 Admin
```
┌──────────────────────────┐
│   Admin Dashboard        │
├──────────────────────────┤
│ ✓ All Features           │
│ ✓ View Statistics        │
│ ✓ Approve Mitras         │
│ ✓ Verify Venues          │
│ ✓ System Management      │
│ ✓ Activity Logs          │
└──────────────────────────┘
```

---

## Data Flow

### Authentication Flow
```
User Input (username/password)
    ↓
LoginPage
    ↓
AuthService.login()
    ↓
ApiService.post('/api/auth/login/')
    ↓
Django Backend (Session Created)
    ↓
Cookies Stored (sessionid, csrftoken)
    ↓
UserProvider (State Updated)
    ↓
Navigate to HomePage
    ↓
All subsequent requests include cookies
```

### Booking Flow
```
Select Venue (HomePage)
    ↓
View Details (VenueDetailPage)
    ↓
Click "Book Now"
    ↓
Select Court (BookingCheckoutPage)
    ↓
Select Date
    ↓
View Available Time Slots
    ↓
Select Time Slot
    ↓
Review Booking Summary
    ↓
Confirm Booking
    ↓
BookingService.createBooking()
    ↓
Django Backend (Booking Created)
    ↓
Success Dialog
    ↓
View in Booking History
```

### Review Flow
```
Complete Booking
    ↓
Navigate to Booking History
    ↓
Click on Completed Booking
    ↓
"Write Review" Button
    ↓
ReviewFormPage
    ↓
Select Rating (1-5 stars)
    ↓
Write Comment
    ↓
Submit Review
    ↓
ReviewService.createReview()
    ↓
Django Backend (Review Saved)
    ↓
Review Appears on Venue Detail
```

---

## API Integration Pattern

```dart
Screen (UI)
    ↓ calls
Service Method
    ↓ uses
ApiService (HTTP Client)
    ↓ sends
HTTP Request + Cookies
    ↓ to
Django API Endpoint
    ↓ returns
JSON Response
    ↓ parsed by
Model.fromJson()
    ↓ updates
Screen State
    ↓ triggers
UI Rebuild
```

---

## State Management

```
┌─────────────────────────────────────┐
│         UserProvider                 │
│    (Global Authentication State)     │
│                                      │
│  - user: User?                       │
│  - loading: bool                     │
│                                      │
│  Methods:                            │
│  - initialize()                      │
│  - login(username, password)         │
│  - register(...)                     │
│  - logout()                          │
│  - updateProfile(...)                │
└─────────────────────────────────────┘
         │
         │ notifies
         ▼
┌─────────────────────────────────────┐
│     All Screens (Consumers)          │
│                                      │
│  - LoginPage                         │
│  - RegisterPage                      │
│  - HomePage                          │
│  - ProfilePage                       │
│  - etc.                              │
└─────────────────────────────────────┘
```

---

## Technology Stack

```
┌──────────────────────────────────────────────┐
│              Presentation Layer              │
│  Flutter Material Design 3 + Custom Widgets  │
├──────────────────────────────────────────────┤
│           State Management Layer             │
│  Provider (UserProvider, ChangeNotifier)     │
├──────────────────────────────────────────────┤
│             Service Layer                    │
│  ApiService, AuthService, VenueService,      │
│  CourtService, BookingService, ReviewService │
├──────────────────────────────────────────────┤
│              Model Layer                     │
│  User, Venue, Court, Booking, Review         │
├──────────────────────────────────────────────┤
│            Network Layer                     │
│  HTTP Client + Cookie Management             │
├──────────────────────────────────────────────┤
│          Django Backend API                  │
│  RESTful APIs + Session Authentication       │
├──────────────────────────────────────────────┤
│            Database Layer                    │
│        SQLite / PostgreSQL                   │
└──────────────────────────────────────────────┘
```

---

## Package Dependencies

```yaml
http: ^1.1.0
├─ API communication
└─ Cookie management

provider: ^6.1.1
├─ State management
└─ Dependency injection

cached_network_image: ^3.3.0
├─ Image caching
└─ Performance optimization

shared_preferences: ^2.2.2
├─ Local storage
└─ Session persistence

intl: ^0.18.1
├─ Date formatting
└─ Number formatting

uuid: ^4.2.1
├─ Generate unique IDs
└─ Request tracking

image_picker: ^1.0.5
├─ Select images
└─ Camera access

url_launcher: ^6.2.1
├─ Open URLs
└─ External navigation
```

---

## Responsive Design

```
┌──────────────────────────────┐
│      All Screen Sizes        │
├──────────────────────────────┤
│  Phone (Portrait)            │
│  ├─ Single column layout     │
│  ├─ Bottom navigation        │
│  └─ Collapsible sections     │
│                              │
│  Phone (Landscape)           │
│  ├─ Wider cards              │
│  └─ Side navigation          │
│                              │
│  Tablet                      │
│  ├─ Multi-column layout      │
│  ├─ Larger text              │
│  └─ More content visible     │
└──────────────────────────────┘
```

---

## Security Features

```
✓ Session-based authentication
✓ CSRF token protection
✓ Secure cookie storage
✓ Role-based access control
✓ Input validation
✓ Error handling
✓ Secure HTTPS (production)
```

---

## Performance Optimizations

```
✓ Image caching
✓ Lazy loading
✓ Infinite scroll
✓ Pull-to-refresh
✓ Local state caching
✓ Minimal rebuilds
✓ Async operations
```

---

## Testing Coverage

```
┌─────────────────────────────┐
│     Manual Testing          │
├─────────────────────────────┤
│ ✓ User registration         │
│ ✓ User login                │
│ ✓ Venue browsing            │
│ ✓ Booking creation          │
│ ✓ Review submission         │
│ ✓ Mitra dashboard           │
│ ✓ Admin dashboard           │
│ ✓ Navigation flows          │
│ ✓ Error handling            │
└─────────────────────────────┘
```

---

## Deployment Checklist

```
Backend (Django):
☐ Configure production database
☐ Set DEBUG = False
☐ Configure ALLOWED_HOSTS
☐ Set up HTTPS
☐ Configure CORS
☐ Set secure cookies

Frontend (Flutter):
☐ Update baseUrl to production
☐ Build release APK/IPA
☐ Test on physical devices
☐ Configure app icons
☐ Set up splash screen
☐ Submit to app stores
```

---

## Maintenance Plan

```
Regular Updates:
├─ Flutter SDK updates
├─ Package dependency updates
├─ Django backend updates
├─ Security patches
└─ Bug fixes

Feature Additions:
├─ Push notifications
├─ Offline mode
├─ Payment gateway
├─ Maps integration
└─ Chat system
```

---

**Status:** ✅ Complete Implementation  
**Next:** Integration Testing with Live Backend
