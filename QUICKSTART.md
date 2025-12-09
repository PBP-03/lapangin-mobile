# LapangIN Mobile - Quick Start Guide

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK
- VS Code or Android Studio
- iOS Simulator / Android Emulator

### Installation

1. **Navigate to project directory**

   ```bash
   cd lapangin_mobile
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure Overview

```
lib/
├── 📱 screens/           # UI Pages (User, Mitra, Admin)
├── 🧩 widgets/           # Reusable components
├── 🔄 providers/         # State management
├── 🌐 services/          # API calls
├── 📊 models/            # Data structures
├── 🛡️ middlewares/       # Route guards
├── 🔧 utils/             # Helper functions
└── 🎨 constants/         # Theme & API constants
```

## 🔐 Role-Based System

### Three User Roles:

1. **👤 User (Penyewa)**

   - Browse venues
   - Make bookings
   - Write reviews
   - View booking history

2. **🏢 Mitra (Pemilik Lapangan)**

   - Manage venues
   - View bookings
   - Track revenue
   - Manage courts

3. **👑 Admin**
   - Oversee platform
   - Manage all users
   - Approve venues
   - View analytics

## 📱 Current Features

### ✅ Implemented

1. **Authentication System**

   - Login page with validation
   - Registration page
   - Role-based authentication
   - Session management (cookies)

2. **State Management**

   - User state provider
   - Global state access
   - Reactive UI updates

3. **Navigation System**

   - Role-based routing
   - Navigation guards
   - Route protection middleware

4. **Dashboard Pages**

   - User home page
   - Mitra home page
   - Admin home page

5. **Development Tools**
   - Role selector page (for testing)
   - Navigation helpers
   - Theme system

### 🔲 To Be Implemented

- Venue browsing & search
- Booking system
- Review system
- Profile management
- Revenue dashboard
- User management
- Analytics & reports

## 🧪 Testing the App

### 1. Login Flow

```dart
// Test credentials (from your Django backend)
Username: your_username
Password: your_password
```

### 2. Role Selector (Development Mode)

After login, you'll see a **Role Selector** page that allows you to navigate to different dashboards:

- **User Dashboard** → Browse and book venues
- **Mitra Dashboard** → Manage venues and bookings
- **Admin Dashboard** → Platform oversight

> **Note**: This role selector is for development only. In production, users will automatically navigate to their role-specific dashboard.

### 3. Navigation Flow

```
Login → Role Selector → User/Mitra/Admin Dashboard
```

## 🎨 Customization

### Theme Colors

Edit `lib/constants/app_theme.dart`:

```dart
class AppColors {
  static const Color primary = Color(0xFF5409DA);
  static const Color secondary = Color(0xFF4E71FF);
  // ... more colors
}
```

### API Endpoints

Edit `lib/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'YOUR_API_URL';
  static const String loginUrl = '$baseUrl/users/login/';
  // ... more endpoints
}
```

## 🔧 Key Files

| File                      | Purpose                       |
| ------------------------- | ----------------------------- |
| `main.dart`               | App entry, routing, providers |
| `login_page.dart`         | Login screen                  |
| `user_provider.dart`      | User state management         |
| `auth_service.dart`       | Authentication API calls      |
| `route_guard.dart`        | Route protection              |
| `role_selector_page.dart` | Dev tool (remove in prod)     |

## 📝 Adding New Features

### 1. Create a Model

```dart
// lib/models/venue.dart
class Venue {
  final String id;
  final String name;
  // ...
}
```

### 2. Create a Service

```dart
// lib/services/venue_service.dart
class VenueService {
  Future<List<Venue>> getVenues() async {
    // API call
  }
}
```

### 3. Create a Provider

```dart
// lib/providers/venue_provider.dart
class VenueProvider extends ChangeNotifier {
  List<Venue> _venues = [];
  // ... state management
}
```

### 4. Create UI Screen

```dart
// lib/screens/user/venue_list_page.dart
class VenueListPage extends StatelessWidget {
  // UI code
}
```

### 5. Add Route

```dart
// In main.dart
routes: {
  '/user/venues': (context) => const VenueListPage(),
}
```

## 🛡️ Route Protection

### Protect a route by role:

```dart
routes: {
  '/mitra/dashboard': (context) => RouteGuard.requireRole(
    context,
    const MitraDashboard(),
    'mitra', // required role
  ),
}
```

## 🚀 Deployment Checklist

Before deploying to production:

- [ ] Remove `role_selector_page.dart`
- [ ] Update login to navigate directly by role
- [ ] Remove development comments
- [ ] Update API endpoints to production
- [ ] Test all role-based features
- [ ] Enable error logging
- [ ] Optimize images and assets
- [ ] Run `flutter build apk --release`
- [ ] Test on physical devices

## 📚 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0 # State management
  pbp_django_auth: ^1.0.0 # Django authentication
```

## 🐛 Troubleshooting

### Issue: "Cannot connect to API"

- Check `api_constants.dart` for correct URL
- Ensure backend is running
- Check network permissions

### Issue: "Login fails"

- Verify credentials
- Check backend logs
- Ensure cookies are enabled

### Issue: "Navigation not working"

- Check route names match exactly
- Verify user is logged in
- Check route guards

## 📞 Support

For issues or questions:

1. Check `FLUTTER_STRUCTURE.md` for architecture details
2. Check `FOLDER_STRUCTURE.md` for complete file organization
3. Review backend API documentation

## 🎯 Next Steps

1. **Implement Venue Listing**

   - Create venue model
   - Create venue service
   - Build UI for venue list

2. **Implement Booking System**

   - Create booking model
   - Create booking service
   - Build booking UI

3. **Add Profile Management**

   - Create profile screens
   - Implement edit functionality
   - Add image upload

4. **Enhance UI/UX**
   - Add animations
   - Improve error handling
   - Add loading states

---

**Happy Coding! 🚀**
