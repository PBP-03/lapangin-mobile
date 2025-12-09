# LapangIN Mobile - Quick Start Guide

## Prerequisites
✅ Flutter SDK installed (3.9.2 or higher)
✅ Django backend running (LapangIN-PBP)
✅ Android Studio / VS Code with Flutter extensions

## Step 1: Configure Backend Connection

Edit `lib/config/config.dart` line 3:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

**For iOS Simulator or Physical Device (on same network):**
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000';
// Example: http://192.168.1.100:8000
```

**For Production:**
```dart
static const String baseUrl = 'https://muhammad-fauzan44-lapangin.pbp.cs.ui.ac.id';
```

## Step 2: Start Django Backend

```bash
cd LapangIN-PBP
python manage.py runserver 0.0.0.0:8000
```

**Important**: Use `0.0.0.0:8000` to allow connections from mobile devices!

## Step 3: Verify Django Settings

In `LapangIN-PBP/lapangin/settings.py`, ensure:

```python
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "10.0.2.2", "*"]

# For development only - remove "*" in production
```

## Step 4: Run Flutter App

```bash
cd lapangin-mobile
flutter run
```

Select your device/emulator when prompted.

## Step 5: Test the App

### 1. Register a New Account
- Open the app (starts at login screen)
- Tap "Register Now"
- Fill in the form:
  - Username: `testuser`
  - First Name: `Test`
  - Last Name: `User`
  - Email: `test@example.com`
  - Password: `test123456`
  - Confirm Password: `test123456`
  - Select role: **User** or **Mitra**
  - Check "I agree to terms"
- Tap "Create Account"

### 2. Login
If registration redirects to login:
- Username: `testuser`
- Password: `test123456`
- Tap "Login"

### 3. Browse Venues
- You should see the home page with venue listings
- Use the search bar to filter venues
- Pull down to refresh
- Scroll down for pagination

### 4. View Profile
- Tap the profile icon in the app bar
- View your account information
- Try the logout function

## Common Issues & Solutions

### ❌ "Network error" or "Connection refused"

**Solution:**
1. Check Django is running: Visit http://localhost:8000 in browser
2. Check base URL in `config.dart`
3. For Android emulator, use `10.0.2.2` NOT `localhost`
4. For physical device, use computer's IP address

### ❌ "CSRF verification failed"

**Solution:**
Add to Django `settings.py`:
```python
CSRF_TRUSTED_ORIGINS = [
    'http://localhost:8000',
    'http://10.0.2.2:8000',
]
```

### ❌ No venues showing

**Solution:**
1. Create venues in Django admin: http://localhost:8000/admin-django/
2. Ensure venue `verification_status` is set to `'approved'`
3. Pull to refresh in the app

### ❌ Flutter build errors

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

## Testing Different User Roles

### Create Test Accounts via Django Admin

1. **Admin User**
   ```bash
   python manage.py createsuperuser
   ```
   Set `role='admin'` in Django admin

2. **Mitra User**
   - Register via app with "Mitra" role selected
   - Or create in Django admin with `role='mitra'`

3. **Regular User**
   - Register via app with "User" role selected
   - Or create in Django admin with `role='user'`

## Seed Data for Testing

Run in Django backend:
```bash
python manage.py loaddata initial_data  # If you have fixtures
```

Or use the Django admin panel to create:
1. Sports Categories (Futsal, Badminton, etc.)
2. Venues (with owner set to a mitra user)
3. Courts (linked to venues)
4. Set venue verification_status to 'approved'

## Development Workflow

1. **Backend Changes**: Restart Django server
2. **Frontend Changes**: Hot reload automatically in Flutter
3. **Model Changes**: May need to restart the Flutter app
4. **Config Changes**: Restart Flutter app

## API Testing

Test API endpoints directly:

```bash
# Check API is working
curl http://localhost:8000/api/public/venues/

# Test login
curl -X POST http://localhost:8000/api/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"test123456"}'
```

## Next Development Steps

After basic setup works:

1. ✅ Test login/register flow
2. ✅ Verify venue listing loads
3. ✅ Test search functionality
4. ✅ Check profile page
5. 🔲 Implement venue detail page
6. 🔲 Add booking flow
7. 🔲 Build mitra dashboard
8. 🔲 Create admin panel

## Production Deployment

### Mobile App
- Update `baseUrl` to production URL
- Build release APK/IPA
- Test on physical devices
- Submit to Play Store/App Store

### Backend
- Ensure Django is deployed and accessible
- Update `ALLOWED_HOSTS` and `CSRF_TRUSTED_ORIGINS`
- Use HTTPS in production
- Test API endpoints from mobile app

## Getting Help

- **Backend Issues**: Check `LapangIN-PBP/README.md`
- **Flutter Issues**: Check `IMPLEMENTATION_GUIDE.md`
- **API Endpoints**: Check `LapangIN-PBP/lapangin/urls.py`

## Success Indicators

✅ Django server running without errors
✅ Flutter app builds successfully  
✅ Login/Register works
✅ Venues load on home page
✅ Search returns filtered results
✅ Profile shows user data
✅ Logout returns to login screen

---

**Tip**: Keep Django terminal and Flutter terminal open side-by-side to see logs from both backend and frontend!
