# Backend Integration Guide

## Overview

This Flutter app is now integrated with the Django backend for authentication (login and register).

## Setup Instructions

### 1. Backend Configuration

Make sure your Django backend is running on:

- **Local development**: `http://localhost:8000` or the appropriate host

### 2. Update API Constants

Edit `lib/constants/api_constants.dart` to match your backend URL:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000';

// For iOS Simulator
static const String baseUrl = 'http://localhost:8000';

// For Physical Device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.100:8000';

// For Production
static const String baseUrl = 'https://your-domain.com';
```

### 3. Django Backend Requirements

Ensure your Django backend has CORS properly configured:

```python
# settings.py
INSTALLED_APPS = [
    ...
    'corsheaders',
    ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    ...
]

# For development
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# For production, specify allowed origins
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8000",
    # Add your production domains
]
```

## API Endpoints Used

### Login

- **Endpoint**: `/api/login/`
- **Method**: POST
- **Payload**:
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Login berhasil! Selamat datang, [Name]",
    "user": {
      "id": "uuid",
      "username": "string",
      "first_name": "string",
      "role": "user|mitra|admin"
    },
    "redirect_url": "string"
  }
  ```

### Register

- **Endpoint**: `/api/register/`
- **Method**: POST
- **Payload**:
  ```json
  {
    "username": "string",
    "email": "string",
    "first_name": "string",
    "last_name": "string",
    "password1": "string",
    "password2": "string",
    "phone_number": "string (optional)",
    "role": "user|mitra"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Registrasi berhasil! Silakan login.",
    "user": {
      "id": "uuid",
      "username": "string",
      "first_name": "string",
      "role": "user|mitra"
    }
  }
  ```

## How to Test

### 1. Start Django Backend

```bash
cd LapangIN-PBP
python manage.py runserver
```

### 2. Run Flutter App

```bash
cd lapangin_mobile
flutter run
```

### 3. Test Registration

1. Open the app (it should start at login page)
2. Click "Register Now"
3. Fill in all required fields:
   - Username
   - First Name
   - Last Name
   - Email
   - Password
   - Confirm Password
   - Phone Number (optional)
   - Select Account Type (User/Penyewa or Mitra/Pemilik Lapangan)
4. Check "I agree to the Terms & Conditions"
5. Click "Create Account"
6. You should be redirected to login page on success

### 4. Test Login

1. Enter your username
2. Enter your password
3. Click "Login"
4. On success, you'll see a welcome message

## Features Implemented

✅ User Registration with backend API
✅ User Login with backend API
✅ Cookie-based authentication using `pbp_django_auth`
✅ Form validation
✅ Error handling and user feedback
✅ Role selection (User/Penyewa or Mitra/Pemilik Lapangan)
✅ Optional phone number field

## Files Modified/Created

### Created Files:

- `lib/models/user.dart` - User model
- `lib/constants/api_constants.dart` - API configuration
- `INTEGRATION_GUIDE.md` - This guide

### Modified Files:

- `lib/main.dart` - Added Provider for CookieRequest
- `lib/screens/login_page.dart` - Integrated login API
- `lib/screens/register_page.dart` - Integrated register API

## Packages Used

- `provider: ^6.1.2` - State management
- `pbp_django_auth: ^1.0.0` - Django authentication
- `http: ^1.6.0` - HTTP requests

## Troubleshooting

### Connection Issues

1. **Android Emulator**: Use `10.0.2.2` instead of `localhost`
2. **iOS Simulator**: Use `localhost`
3. **Physical Device**: Use your computer's local IP address

### CORS Errors

- Make sure `django-cors-headers` is installed
- Check CORS settings in Django `settings.py`
- Ensure `CORS_ALLOW_CREDENTIALS = True`

### Authentication Errors

- Verify backend is running
- Check API endpoints match
- Ensure Django session middleware is enabled

## Next Steps

🔲 Create home page/dashboard after login
🔲 Implement logout functionality
🔲 Add persistent login (save session)
🔲 Add forgot password feature
🔲 Implement role-based navigation (User vs Mitra dashboards)
🔲 Add profile management

## Contact

For issues or questions, please check the backend API documentation or contact the backend team.
