# 🌍 Travel Assistant App

A beautiful, full-stack AI-powered Travel Assistant App built with **Flutter (frontend)** and **Django (backend)**.

## ✨ Features

- 🔍 **Place Search** - Search for any destination
- 📸 **Beautiful Images** - High-quality images from Unsplash
- 🌤️ **Weather Information** - Real-time weather data
- 🗺️ **Route Planning** - Distance and travel time calculation
- 🏨 **Hotel Recommendations** - Nearby hotel suggestions
- 📅 **AI-Generated Itineraries** - Personalized 1-3 day travel plans
- 💬 **AI Chat Assistant** - Interactive chat for travel queries
- ⭐ **Top Tourist Spots** - Must-visit attractions
- 🎨 **Modern UI** - Smooth animations and beautiful design

## 📁 Project Structure

```
travel_assistant/
├── backend/           # Django REST API
│   ├── api/          # API endpoints and services
│   ├── travel_assistant/  # Django settings
│   └── manage.py
├── frontend/         # Flutter app
│   ├── lib/
│   │   ├── screens/  # UI screens
│   │   ├── widgets/  # Reusable widgets
│   │   ├── models/   # Data models
│   │   ├── api/      # API client
│   │   └── providers/ # State management
│   └── pubspec.yaml
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Python 3.9+
- Flutter 3.0+
- Django 4.2+
- Ollama (for AI features) - [Install Ollama](https://ollama.ai)

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   
   # On Windows
   venv\Scripts\activate
   
   # On macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Create `.env` file:**
   ```bash
   cp .env.example .env
   ```

5. **Edit `.env` file and add your API keys:**
   ```env
   SECRET_KEY=your-secret-key-here
   UNSPLASH_ACCESS_KEY=your-unsplash-access-key
   OPENWEATHER_API_KEY=your-openweather-api-key
   OPENROUTESERVICE_API_KEY=your-openrouteservice-api-key
   OLLAMA_BASE_URL=http://localhost:11434
   ```

   **Get API Keys:**
   - **Unsplash**: Sign up at [unsplash.com/developers](https://unsplash.com/developers)
   - **OpenWeatherMap**: Get free API key at [openweathermap.org/api](https://openweathermap.org/api)
   - **OpenRouteService**: Sign up at [openrouteservice.org](https://openrouteservice.org/dev/#/signup)

6. **Run migrations:**
   ```bash
   python manage.py migrate
   ```

7. **Start Django server:**
   ```bash
   python manage.py runserver
   ```

   Backend will run on `http://localhost:8000`

8. **Set up Ollama (for AI features):**
   ```bash
   # Install Ollama from https://ollama.ai
   # Then pull the Llama 3.1 model:
   ollama pull llama3.1
   ```

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (for JSON serialization and Retrofit):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Update API base URL (if needed):**
   
   Edit `frontend/lib/api/api_client.dart` and change the baseUrl if your backend is running on a different address:
   ```dart
   @RestApi(baseUrl: "http://YOUR_IP:8000/api")  // For Android emulator, use 10.0.2.2
   ```

   **Important for Android Emulator:**
   - Use `http://10.0.2.2:8000/api` instead of `localhost`
   - For iOS Simulator, `localhost` works fine
   - For physical devices, use your computer's IP address

5. **Run Flutter app:**
   ```bash
   flutter run
   ```

## 📱 Usage

### Home Screen
- Use the search bar to find any destination
- Tap on quick suggestions (Goa, Pune, Delhi, Jaipur)
- Browse top destinations grid
- Tap "Ask AI Assistant" to open chat

### Place Details Screen
- View beautiful hero images
- Check weather information
- See route and distance
- Browse top tourist spots (swipe horizontally)
- View hotel recommendations
- Read AI-generated itinerary
- Check fun facts

### Chat Screen
- Ask questions about destinations
- Get personalized travel advice
- Request itinerary details
- Ask about weather, hotels, and more

## 🔧 Configuration

### Backend API Endpoints

- `POST /api/travel/info/` - Get comprehensive travel information
  ```json
  {
    "place": "Pune",
    "user_location": "Mumbai"
  }
  ```

### Frontend API Client

The Flutter app uses Riverpod for state management and Retrofit for API calls. The API client is automatically generated using build_runner.

## 🛠️ Technologies Used

### Backend
- Django 4.2
- Django REST Framework
- Python 3.9+
- Ollama (Llama 3.1)
- External APIs: Wikipedia, Unsplash, OpenWeatherMap, OpenRouteService

### Frontend
- Flutter 3.0+
- Riverpod (State Management)
- Retrofit (API Client)
- Carousel Slider
- Shimmer (Loading States)
- Cached Network Image
- Google Fonts
- Staggered Animations

## 🎨 UI Features

- Modern gradient designs
- Smooth animations
- Pull-to-refresh
- Shimmer loading states
- Hero image transitions
- Card-based layouts
- Responsive design

## 📝 API Keys Setup

### 1. Unsplash API Key
1. Go to [unsplash.com/developers](https://unsplash.com/developers)
2. Create a new application
3. Copy the Access Key
4. Add to `.env`: `UNSPLASH_ACCESS_KEY=your-key-here`

### 2. OpenWeatherMap API Key
1. Sign up at [openweathermap.org](https://openweathermap.org/api)
2. Go to API Keys section
3. Generate a new key
4. Add to `.env`: `OPENWEATHER_API_KEY=your-key-here`

### 3. OpenRouteService API Key
1. Sign up at [openrouteservice.org](https://openrouteservice.org/dev/#/signup)
2. Get your API key from dashboard
3. Add to `.env`: `OPENROUTESERVICE_API_KEY=your-key-here`

### 4. Ollama Setup
1. Install Ollama from [ollama.ai](https://ollama.ai)
2. Pull Llama 3.1 model:
   ```bash
   ollama pull llama3.1
   ```
3. Start Ollama service (usually runs automatically)
4. Verify in `.env`: `OLLAMA_BASE_URL=http://localhost:11434`

## 🐛 Troubleshooting

### Backend Issues

**Issue:** API keys not working
- **Solution:** Double-check `.env` file and ensure keys are correctly set

**Issue:** Ollama connection error
- **Solution:** Make sure Ollama is running: `ollama serve`
- Verify model is installed: `ollama list`

**Issue:** CORS errors
- **Solution:** Django CORS is configured to allow all origins in development

### Frontend Issues

**Issue:** Cannot connect to backend
- **Solution:** Update baseUrl in `api_client.dart` to match your setup
  - Android Emulator: `http://10.0.2.2:8000/api`
  - iOS Simulator: `http://localhost:8000/api`
  - Physical Device: `http://YOUR_COMPUTER_IP:8000/api`

**Issue:** Build runner errors
- **Solution:** Run with `--delete-conflicting-outputs` flag:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

**Issue:** Dependencies not found
- **Solution:** Run `flutter pub get` and ensure Flutter SDK is up to date

## 📦 Production Deployment

### Backend
- Set `DEBUG = False` in settings.py
- Use a production WSGI server (Gunicorn)
- Set up proper database (PostgreSQL)
- Configure proper CORS settings
- Use environment variables for secrets

### Frontend
- Build release APK/IPA:
  ```bash
  flutter build apk  # Android
  flutter build ios  # iOS
  ```
- Update API baseUrl to production URL
- Enable code obfuscation for smaller builds

## 🤝 Contributing

Feel free to contribute by:
1. Forking the repository
2. Creating a feature branch
3. Making your changes
4. Submitting a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- External APIs: Wikipedia, Unsplash, OpenWeatherMap, OpenRouteService
- AI Model: Llama 3.1 via Ollama
- UI Inspiration: Modern travel app designs

## 📧 Support

For issues and questions, please open an issue on GitHub.

---

**Built with ❤️ using Flutter & Django**

