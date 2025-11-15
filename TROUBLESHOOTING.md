# 🔧 Troubleshooting Guide

## ✅ API is Working!

The Django API is working correctly. Test it:
```powershell
$body = @{place='Pune'} | ConvertTo-Json
Invoke-WebRequest -Uri 'http://localhost:8000/api/travel/info/' -Method POST -Body $body -ContentType 'application/json'
```

## 🐛 Common Issues

### 1. Flutter App Not Calling API

**Check Console Logs:**
When you tap on a city chip, you should see:
- `🔍 Searching for place: [CityName]`
- `🏗️ Building PlaceDetailsScreen for: [CityName]`
- `🔧 Creating ApiClient with baseUrl: [URL]`
- `🌍 Fetching travel info for: [CityName]`
- `📡 API Base URL: [URL]`
- `📤 Request body: {...}`

**If you don't see these logs:**
1. Check if the screen is navigating correctly
2. Check if the provider is being called
3. Verify the API base URL is correct for your platform

### 2. Wrong API URL

**For Android Emulator:**
- Use: `http://10.0.2.2:8000/api`
- This is already set in `ApiConfig`

**For iOS Simulator:**
- Use: `http://localhost:8000/api`
- This is already set in `ApiConfig`

**For Physical Device:**
- You need your computer's IP address
- Find it: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Update `frontend/lib/config/api_config.dart`:
  ```dart
  static const String baseUrl = 'http://YOUR_IP:8000/api';
  ```

### 3. CORS Errors

Django CORS is already configured. If you see CORS errors:
- Make sure `django-cors-headers` is installed
- Check `CORS_ALLOW_ALL_ORIGINS = True` in settings.py

### 4. Network Errors

**Error: SocketException or Connection refused**
- Make sure Django server is running: `python manage.py runserver`
- Check the server is on port 8000
- Verify the URL in `ApiConfig` matches your setup

### 5. 404 Errors

**If you see 404 for `/api/travel/info/`:**
- Check Django URLs are correct
- Verify the endpoint path: `/api/travel/info/` (with trailing slash)
- Make sure you're using POST method, not GET

## 🔍 Debug Steps

1. **Check Django Server:**
   ```powershell
   # Should see: "Starting development server at http://127.0.0.1:8000/"
   ```

2. **Test API Manually:**
   ```powershell
   $body = @{place='Pune'} | ConvertTo-Json
   Invoke-WebRequest -Uri 'http://localhost:8000/api/travel/info/' -Method POST -Body $body -ContentType 'application/json'
   ```

3. **Check Flutter Logs:**
   - Look for the emoji logs (🔍, 🏗️, 🔧, 🌍, etc.)
   - Check for error messages
   - Verify the API URL being used

4. **Verify Network:**
   - Android Emulator: `http://10.0.2.2:8000/api`
   - iOS Simulator: `http://localhost:8000/api`
   - Physical Device: Your computer's IP

## ✅ Quick Fixes

### Update API URL for Physical Device:
Edit `frontend/lib/config/api_config.dart`:
```dart
static String get baseUrl {
  // For physical device, replace with your computer's IP
  return 'http://192.168.1.XXX:8000/api';  // Your IP here
}
```

### Check Django is Running:
```powershell
cd backend
python manage.py runserver
```

### Restart Flutter App:
```powershell
cd frontend
flutter run
```

