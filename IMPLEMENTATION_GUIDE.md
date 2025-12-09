# LapangIN Mobile - Flutter Implementation

## Overview
This is the Flutter mobile application for LapangIN, a platform for booking sports venues. The mobile app connects to the Django backend (LapangIN-PBP) and provides a native mobile experience for users to browse venues, make bookings, and manage their accounts.

## Implementation Status

### ✅ Completed Features

#### 1. **Project Setup & Dependencies**
- Flutter project structure initialized
- Required packages installed:
  - `http` for API communication
  - `provider` for state management
  - `shared_preferences` for local storage
  - `cached_network_image` for image loading
  - `intl` for date/time formatting
  - `uuid` for ID handling
  - `image_picker` for image uploads
  - `url_launcher` for external links

#### 2. **Configuration & API Integration**
- `AppConfig` class created with all API endpoints
- Base URL configuration (supports both local and production)
- API service layer with cookie-based authentication
- Automatic session management with SharedPreferences

#### 3. **Data Models**
All Django models converted to Dart models:
- `User` - User account with role-based access (user, mitra, admin)
- `Venue` - Sports venue information
- `Court` - Individual courts within venues
- `CourtSession` - Time slots for courts
- `Booking` - Booking information
- `Payment` - Payment details
- `Review` - Venue reviews
- `SportsCategory` - Sports categories (Futsal, Badminton, etc.)

#### 4. **Service Layer**
API services implemented:
- `AuthService` - Login, register, logout, profile management
- `VenueService` - Venue listing, details, search, CRUD operations
- `CourtService` - Court management, sessions
- `BookingService` - Create bookings, payment handling
- `ReviewService` - Review submission and management

#### 5. **State Management**
- `UserProvider` - Manages authentication state and user data
- Auto-initialization on app start
- Persistent session across app restarts

#### 6. **Authentication Screens**
- **Login Page** 
  - Username/password authentication
  - Connected to Django backend
  - Role-based navigation (User/Mitra/Admin)
  - Modern UI with purple theme
  
- **Register Page**
  - User registration with role selection (User or Mitra)
  - Form validation
  - Auto-login after successful registration
  - Terms and conditions checkbox

#### 7. **Main Application Screens**
- **Home Page**
  - Venue listing with pagination
  - Search functionality
  - Pull-to-refresh
  - Infinite scroll loading
  - Venue cards with images, ratings, prices
  - Connected to Django API
  
- **Profile Page**
  - User information display
  - Account details
  - Menu options (Booking History, Edit Profile, Settings)
  - Logout functionality

### 🚧 Remaining Features to Implement

The foundation is complete! Here's what remains to build out the full functionality:

#### 1. **Venue Details & Booking Flow**
- Venue detail page with full information
- Court selection interface
- Date/time picker for bookings
- Booking confirmation screen
- Payment method selection
- Payment proof upload

#### 2. **Booking Management**
- Booking history list
- Booking details view
- Cancel booking functionality
- Payment status tracking

#### 3. **Review System**
- Submit review after completed booking
- View reviews on venue pages
- Edit/delete own reviews
- Rating display

#### 4. **Mitra Dashboard** (for venue owners)
- My venues list
- Add/edit venue functionality
- Court management (add/edit/delete)
- Booking management for owned venues
- Revenue tracking
- Statistics dashboard

#### 5. **Admin Dashboard** (for administrators)
- Mitra approval system
- Venue verification
- User management
- System statistics
- Revenue overview

#### 6. **Additional Features**
- Edit profile functionality
- Change password
- Notification system
- Favorites/wishlist
- Filter venues by category, price, location
- Map integration for venue locations
- Image upload for venues and courts

## Backend Configuration

### Django Settings Required

Ensure your Django backend (`LapangIN-PBP`) is configured to accept requests from the mobile app:

1. **CORS Settings** (if using different domains):
```python
INSTALLED_APPS = [
    ...
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    ...
]

CORS_ALLOWED_ORIGINS = [
    "http://localhost:8000",
]

CORS_ALLOW_CREDENTIALS = True
```

2. **CSRF Settings**:
```python
CSRF_COOKIE_SAMESITE = 'Lax'
CSRF_COOKIE_HTTPONLY = False
SESSION_COOKIE_SAMESITE = 'Lax'
```

3. **Session Settings**:
```python
SESSION_COOKIE_AGE = 1209600  # 2 weeks
SESSION_SAVE_EVERY_REQUEST = True
```

## Running the Application

### 1. Start Django Backend
```bash
cd LapangIN-PBP
python manage.py runserver
```

### 2. Configure API Base URL
Edit `lib/config/config.dart`:
```dart
// For local development
static const String baseUrl = 'http://localhost:8000';

// For production
// static const String baseUrl = 'https://muhammad-fauzan44-lapangin.pbp.cs.ui.ac.id';

// For Android emulator connecting to local host
// static const String baseUrl = 'http://10.0.2.2:8000';
```

### 3. Run Flutter App
```bash
cd lapangin-mobile
flutter run
```

## Project Structure

```
lib/
├── config/
│   └── config.dart              # API configuration
├── models/
│   ├── user_model.dart         # User data model
│   ├── venue_model.dart        # Venue data model
│   ├── court_model.dart        # Court data model
│   ├── booking_model.dart      # Booking data model
│   └── review_model.dart       # Review data model
├── providers/
│   └── user_provider.dart      # User state management
├── services/
│   ├── api_service.dart        # Base API service
│   ├── auth_service.dart       # Authentication API
│   ├── venue_service.dart      # Venue API
│   ├── court_service.dart      # Court API
│   ├── booking_service.dart    # Booking API
│   └── review_service.dart     # Review API
├── screens/
│   ├── login_page.dart         # Login screen
│   ├── register_page.dart      # Registration screen
│   ├── home_page.dart          # Home/venue list screen
│   └── profile_page.dart       # User profile screen
└── main.dart                   # App entry point
```

## API Integration Details

### Authentication Flow
1. User logs in with username/password
2. Django returns session cookie
3. Cookie stored in SharedPreferences
4. Cookie automatically included in all subsequent requests
5. Session persists across app restarts

### Data Synchronization
- All data is fetched from Django backend
- No local database - single source of truth
- Real-time updates when backend changes
- Supports pagination for large datasets

## Design System

### Colors
- Primary: `#5409DA` (Purple)
- Secondary: `#4E71FF` (Blue)
- Background: `#FAFAFA` (Light Gray)

### Typography
- Font Family: Inter (default)
- Heading: Bold, 18-24px
- Body: Regular, 14-16px
- Caption: Regular, 12px

## Testing

### Test User Accounts
Create test accounts in Django admin:
1. Regular User: `role='user'`
2. Mitra (Venue Owner): `role='mitra'`
3. Admin: `role='admin'`

### Test Flow
1. Register as a new user
2. Login with credentials
3. Browse venue list
4. View profile
5. Test search functionality
6. Try logging out and back in

## Troubleshooting

### Connection Issues
- Ensure Django server is running
- Check base URL in `config.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For iOS simulator, use `localhost` or actual IP address

### Authentication Issues
- Clear app data if session is corrupted
- Check CSRF and CORS settings in Django
- Verify cookies are being sent/received

### UI Issues
- Run `flutter clean` and `flutter pub get`
- Check console for error messages
- Ensure all dependencies are installed

## Next Steps

1. **Immediate Priority**: Implement venue detail page and booking flow
2. **User Features**: Complete booking management and reviews
3. **Mitra Features**: Build venue owner dashboard
4. **Admin Features**: Implement admin controls
5. **Polish**: Add animations, loading states, error handling
6. **Testing**: Comprehensive testing on real devices
7. **Deployment**: Prepare for production release

## Notes

- The app uses **cookie-based authentication** (matching Django's session auth)
- All API endpoints match the Django backend structure
- Models are designed to serialize/deserialize Django JSON responses
- State management uses Provider pattern (can be upgraded to Riverpod/Bloc if needed)
- UI follows Material Design 3 guidelines
- Code is structured for maintainability and scalability

## Contact & Support

For issues or questions about the Flutter implementation, refer to the Django backend documentation in `LapangIN-PBP/README.md` for API details.
