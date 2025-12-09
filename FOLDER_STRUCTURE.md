# LapangIN Mobile - Complete Folder Structure

```
lapangin_mobile/
│
├── lib/
│   ├── main.dart                                    # ✅ Entry point, routing, providers
│   │
│   ├── constants/                                   # Application constants
│   │   ├── api_constants.dart                       # ✅ API endpoints
│   │   └── app_theme.dart                           # ✅ Theme colors, text styles
│   │
│   ├── models/                                      # Data models
│   │   ├── user.dart                                # ✅ User model
│   │   ├── venue.dart                               # 🔲 Venue model (TODO)
│   │   ├── booking.dart                             # 🔲 Booking model (TODO)
│   │   ├── court.dart                               # 🔲 Court model (TODO)
│   │   └── review.dart                              # 🔲 Review model (TODO)
│   │
│   ├── providers/                                   # State management
│   │   ├── user_provider.dart                       # ✅ User state provider
│   │   ├── venue_provider.dart                      # 🔲 Venue state (TODO)
│   │   └── booking_provider.dart                    # 🔲 Booking state (TODO)
│   │
│   ├── services/                                    # API service layer
│   │   ├── auth_service.dart                        # ✅ Authentication API calls
│   │   ├── venue_service.dart                       # 🔲 Venue API calls (TODO)
│   │   ├── booking_service.dart                     # 🔲 Booking API calls (TODO)
│   │   ├── review_service.dart                      # 🔲 Review API calls (TODO)
│   │   └── user_service.dart                        # 🔲 User API calls (TODO)
│   │
│   ├── middlewares/                                 # Route guards & middleware
│   │   └── route_guard.dart                         # ✅ Authentication & role guards
│   │
│   ├── utils/                                       # Utility functions
│   │   ├── app_navigator.dart                       # ✅ Navigation helpers
│   │   ├── validators.dart                          # 🔲 Form validators (TODO)
│   │   ├── formatters.dart                          # 🔲 Data formatters (TODO)
│   │   └── date_utils.dart                          # 🔲 Date utilities (TODO)
│   │
│   ├── screens/                                     # UI screens
│   │   │
│   │   ├── login_page.dart                          # ✅ Login screen
│   │   ├── register_page.dart                       # ✅ Registration screen
│   │   │
│   │   ├── user/                                    # 👤 USER ROLE SCREENS
│   │   │   ├── user_home_page.dart                  # ✅ User dashboard
│   │   │   ├── venue_list_page.dart                 # 🔲 Browse venues (TODO)
│   │   │   ├── venue_detail_page.dart               # 🔲 Venue details (TODO)
│   │   │   ├── booking_page.dart                    # 🔲 Create booking (TODO)
│   │   │   ├── booking_history_page.dart            # 🔲 Booking history (TODO)
│   │   │   ├── user_profile_page.dart               # 🔲 User profile (TODO)
│   │   │   └── review_page.dart                     # 🔲 Write reviews (TODO)
│   │   │
│   │   ├── mitra/                                   # 🏢 MITRA ROLE SCREENS
│   │   │   ├── mitra_home_page.dart                 # ✅ Mitra dashboard
│   │   │   ├── venue_management_page.dart           # 🔲 Manage venues (TODO)
│   │   │   ├── venue_form_page.dart                 # 🔲 Add/Edit venue (TODO)
│   │   │   ├── booking_list_page.dart               # 🔲 View bookings (TODO)
│   │   │   ├── revenue_page.dart                    # 🔲 Revenue stats (TODO)
│   │   │   ├── mitra_profile_page.dart              # 🔲 Mitra profile (TODO)
│   │   │   └── court_management_page.dart           # 🔲 Manage courts (TODO)
│   │   │
│   │   └── admin/                                   # 👑 ADMIN ROLE SCREENS
│   │       ├── admin_home_page.dart                 # ✅ Admin dashboard
│   │       ├── user_management_page.dart            # 🔲 Manage users (TODO)
│   │       ├── venue_approval_page.dart             # 🔲 Approve venues (TODO)
│   │       ├── platform_stats_page.dart             # 🔲 Platform statistics (TODO)
│   │       ├── admin_settings_page.dart             # 🔲 Admin settings (TODO)
│   │       └── activity_log_page.dart               # 🔲 Activity logs (TODO)
│   │
│   └── widgets/                                     # Reusable widgets
│       ├── role_selector_page.dart                  # ✅ Role selector (DEV ONLY)
│       ├── custom_app_bar.dart                      # 🔲 Custom AppBar (TODO)
│       ├── custom_button.dart                       # 🔲 Custom Button (TODO)
│       ├── custom_text_field.dart                   # 🔲 Custom TextField (TODO)
│       ├── loading_widget.dart                      # 🔲 Loading indicator (TODO)
│       ├── error_widget.dart                        # 🔲 Error display (TODO)
│       ├── venue_card.dart                          # 🔲 Venue card (TODO)
│       ├── booking_card.dart                        # 🔲 Booking card (TODO)
│       └── bottom_nav_bar.dart                      # 🔲 Bottom navigation (TODO)
│
├── assets/                                          # Static assets
│   ├── images/                                      # Image files
│   ├── icons/                                       # Icon files
│   └── fonts/                                       # Custom fonts
│
├── test/                                            # Unit & widget tests
│   ├── widget_test.dart
│   ├── models/
│   ├── services/
│   └── providers/
│
├── pubspec.yaml                                     # Dependencies
├── analysis_options.yaml                            # Linting rules
└── README.md                                        # Project documentation
```

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Screens   │  │   Widgets    │  │    Routes    │      │
│  │  (UI Pages)  │  │ (Components) │  │ (Navigation) │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼──────────────┐
│         ▼                  ▼                  ▼              │
│                    STATE MANAGEMENT LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │UserProvider  │  │VenueProvider │  │BookProvider  │      │
│  │(ChangeNotify)│  │(ChangeNotify)│  │(ChangeNotify)│      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼──────────────┐
│         ▼                  ▼                  ▼              │
│                      BUSINESS LOGIC LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │AuthService   │  │VenueService  │  │BookingService│      │
│  │(API Calls)   │  │(API Calls)   │  │(API Calls)   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
          └──────────────────┴──────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                            ▼                                  │
│                     DATA LAYER                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │     Models   │  │  CookieReq   │  │  Constants   │       │
│  │  (Data DTOs) │  │ (HTTP Client)│  │  (API URLs)  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└───────────────────────────────────────────────────────────────┘
```

## 🔄 Authentication Flow

```
┌─────────┐
│  Login  │
│  Page   │
└────┬────┘
     │
     ▼
┌──────────────┐
│ AuthService  │ ──────┐
│   .login()   │       │
└──────┬───────┘       │
       │               ▼
       │          ┌──────────┐
       │          │ Backend  │
       │          │   API    │
       │          └─────┬────┘
       │                │
       ▼                ▼
┌──────────────┐   (Success)
│ UserProvider │   (User Data)
│  .setUser()  │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│  Role Detection  │
└────┬──┬──┬───────┘
     │  │  │
     ▼  ▼  ▼
 ┌────┬────┬────┐
 │User│Mitra│Admin│
 │Home│Home │Home │
 └────┴────┴─────┘
```

## 🎯 Role-Based Feature Matrix

| Feature             | User | Mitra | Admin |
| ------------------- | ---- | ----- | ----- |
| Browse Venues       | ✅   | ✅    | ✅    |
| Make Bookings       | ✅   | ❌    | ✅    |
| Manage Own Venues   | ❌   | ✅    | ❌    |
| View All Bookings   | ❌   | ✅    | ✅    |
| Approve Venues      | ❌   | ❌    | ✅    |
| User Management     | ❌   | ❌    | ✅    |
| Write Reviews       | ✅   | ❌    | ✅    |
| Revenue Dashboard   | ❌   | ✅    | ✅    |
| Platform Statistics | ❌   | ❌    | ✅    |

## 📝 Notes

✅ = Implemented
🔲 = To be implemented
DEV ONLY = Remove before production deployment
