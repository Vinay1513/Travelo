# 🚀 Quick Start Guide

## ✅ Django Backend Setup (COMPLETED)

All dependencies are installed! The server should be running.

### To Run Django Server:
```powershell
cd backend
python manage.py runserver
```

Server runs on: **http://127.0.0.1:8000/**

### To Stop Server:
Press `Ctrl+C` in the terminal

---

## 📱 Flutter Frontend Setup

### 1. Navigate to Frontend
```powershell
cd frontend
```

### 2. Install Dependencies (Already Done ✅)
```powershell
flutter pub get
```

### 3. Generate Code (Already Done ✅)
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Update API URL (IMPORTANT!)
Edit `frontend/lib/api/api_client.dart`:

**For Android Emulator:**
```dart
@RestApi(baseUrl: "http://10.0.2.2:8000/api")
```

**For iOS Simulator:**
```dart
@RestApi(baseUrl: "http://localhost:8000/api")
```

**For Physical Device:**
```dart
@RestApi(baseUrl: "http://YOUR_COMPUTER_IP:8000/api")
```
(Find your IP: `ipconfig` in PowerShell)

### 5. Run Flutter App
```powershell
flutter run
```

---

## 🤖 About Chat UI Package

**Why Custom Implementation Instead of `flutter_gen_ai_chat_ui`?**

1. **Package Availability**: The `flutter_gen_ai_chat_ui` package version `^0.1.0` was not available in pub.dev when we tried to install it.

2. **Custom Benefits**:
   - ✅ Full control over UI/UX design
   - ✅ Tailored to your travel app needs
   - ✅ No external dependencies
   - ✅ Easy to customize and extend
   - ✅ Better integration with your app's theme

3. **Current Implementation**:
   - Beautiful chat bubbles
   - Smooth animations
   - Context-aware responses
   - Easy to connect to your backend/Ollama

4. **If You Want to Use a Package**:
   - Try `flutter_chat_ui` or `flutter_chat_bubble`
   - Or keep the custom implementation (recommended)

---

## 🔧 API Keys Setup

Edit `backend/.env` file:

```env
SECRET_KEY=django-insecure-change-this-in-production
UNSPLASH_ACCESS_KEY=your-key-here
OPENWEATHER_API_KEY=your-key-here
OPENROUTESERVICE_API_KEY=your-key-here
OLLAMA_BASE_URL=http://localhost:11434
```

**Note**: App works without API keys (uses mock data).

---

## ✅ Status

- ✅ Django backend setup complete
- ✅ Dependencies installed
- ✅ Migrations applied
- ✅ Flutter project created
- ✅ Flutter dependencies installed
- ✅ Code generation complete

**Ready to run!** 🎉

