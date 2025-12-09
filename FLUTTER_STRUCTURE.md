# LapangIN Mobile - Flutter Project Structure

## 📁 Project Structure

```
lib/
├── main.dart                          # Application entry point with routing
├── constants/
│   └── api_constants.dart             # API endpoints and constants
├── models/
│   └── user.dart                      # User data model
├── providers/
│   └── user_provider.dart             # User state management (ChangeNotifier)
├── services/
│   └── auth_service.dart              # Authentication service layer
├── screens/
│   ├── login_page.dart                # Login screen
│   ├── register_page.dart             # Registration screen
│   ├── user/                          # User role screens
│   │   └── user_home_page.dart        # User dashboard
│   ├── mitra/                         # Mitra role screens
│   │   └── mitra_home_page.dart       # Mitra dashboard
│   └── admin/                         # Admin role screens
│       └── admin_home_page.dart       # Admin dashboard
└── widgets/
    └── role_selector_page.dart        # Temporary role selector (dev only)
```

## 🎯 Architecture Overview

### **Role-Based Authentication**

The app supports three user roles:

- **User**: Browse venues and make bookings
- **Mitra**: Manage venues and view bookings
- **Admin**: Oversee platform activities

### **State Management**

- Uses `Provider` package for state management
- `UserProvider`: Manages user authentication state across the app
- `CookieRequest`: Handles HTTP requests with cookie-based auth

### **Service Layer**

- `AuthService`: Handles all authentication operations (login, register, logout)
- Separates business logic from UI components

## 🚀 Key Features

### **1. Authentication Flow**

```
Login → AuthService → UserProvider → Role-based Navigation
```

### **2. Role-Based Navigation**

After successful login:

- User role → `/user/home`
- Mitra role → `/mitra/home`
- Admin role → `/admin/home`

### **3. Temporary Role Selector (Development)**

- Route: `/role-selector`
- Shows after login for easy testing
- Allows quick navigation between role dashboards
- **TODO**: Remove in production

## 📝 Usage Guide

### **Login Implementation**

```dart
final authService = AuthService(request);
final result = await authService.login(username, password);

if (result['success']) {
  final user = result['user'] as User;
  userProvider.setUser(user);
  // Navigate based on user.role
}
```

### **Checking User Role**

```dart
final userProvider = Provider.of<UserProvider>(context);

if (userProvider.isUser) {
  // User-specific logic
} else if (userProvider.isMitra) {
  // Mitra-specific logic
} else if (userProvider.isAdmin) {
  // Admin-specific logic
}
```

### **Logout**

```dart
userProvider.logout();
Navigator.pushReplacementNamed(context, '/login');
```

## 🔐 Security Considerations

1. **Cookie-based Authentication**: Uses `pbp_django_auth` for secure session management
2. **Role-based Access Control**: Backend validates user roles
3. **Secure Navigation**: Routes protected by authentication state

## 🛠️ Future Enhancements

### **User Role Screens (To be implemented)**

```
screens/user/
├── user_home_page.dart          ✅ Done
├── venue_list_page.dart         🔲 TODO
├── venue_detail_page.dart       🔲 TODO
├── booking_page.dart            🔲 TODO
├── booking_history_page.dart    🔲 TODO
└── user_profile_page.dart       🔲 TODO
```

### **Mitra Role Screens (To be implemented)**

```
screens/mitra/
├── mitra_home_page.dart         ✅ Done
├── venue_management_page.dart   🔲 TODO
├── booking_list_page.dart       🔲 TODO
├── revenue_page.dart            🔲 TODO
└── mitra_profile_page.dart      🔲 TODO
```

### **Admin Role Screens (To be implemented)**

```
screens/admin/
├── admin_home_page.dart         ✅ Done
├── user_management_page.dart    🔲 TODO
├── venue_approval_page.dart     🔲 TODO
├── platform_stats_page.dart     🔲 TODO
└── admin_settings_page.dart     🔲 TODO
```

### **Shared Widgets (To be implemented)**

```
widgets/
├── role_selector_page.dart      ✅ Done (Temporary)
├── custom_app_bar.dart          🔲 TODO
├── custom_button.dart           🔲 TODO
├── custom_text_field.dart       🔲 TODO
├── loading_widget.dart          🔲 TODO
└── error_widget.dart            🔲 TODO
```

### **Additional Services (To be implemented)**

```
services/
├── auth_service.dart            ✅ Done
├── venue_service.dart           🔲 TODO
├── booking_service.dart         🔲 TODO
├── review_service.dart          🔲 TODO
└── user_service.dart            🔲 TODO
```

### **Models (To be implemented)**

```
models/
├── user.dart                    ✅ Done
├── venue.dart                   🔲 TODO
├── booking.dart                 🔲 TODO
├── court.dart                   🔲 TODO
└── review.dart                  🔲 TODO
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  pbp_django_auth: ^1.0.0
```

## 🔄 Production Deployment Checklist

- [ ] Remove `role_selector_page.dart`
- [ ] Update login flow to navigate directly based on role
- [ ] Remove development comments from code
- [ ] Add proper error handling and logging
- [ ] Implement proper route guards
- [ ] Add analytics tracking
- [ ] Optimize images and assets

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web (with platform-specific considerations)

## 🤝 Contributing

When adding new features:

1. Follow the existing folder structure
2. Create services for API calls
3. Use providers for state management
4. Separate UI from business logic
5. Add proper documentation

---

**Note**: The `role_selector_page.dart` is for development purposes only. In production, users should be automatically routed to their role-specific dashboard after login.
