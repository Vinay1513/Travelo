# 🔑 API Keys Setup

## Current Status

✅ **Weather API Key Added**: `a66f410cb7cdd3f1deda35cb2306b736`

⚠️ **Note**: The API key appears to be invalid or not activated yet. The app will use mock weather data until a valid key is provided.

## How to Set Up API Keys

### Option 1: Use the setup script
```bash
cd backend
python setup_env.py
```

### Option 2: Create .env file manually
Create a file named `.env` in the `backend/` directory with:
```env
SECRET_KEY=django-insecure-change-this-in-production-xyz123
UNSPLASH_ACCESS_KEY=your-unsplash-key-here
OPENWEATHER_API_KEY=a66f410cb7cdd3f1deda35cb2306b736
OPENROUTESERVICE_API_KEY=your-openrouteservice-key-here
OLLAMA_BASE_URL=http://localhost:11434
```

## Getting Valid API Keys

### OpenWeatherMap API Key
1. Go to: https://openweathermap.org/api
2. Sign up for a free account
3. Get your API key from the dashboard
4. Note: Free tier API keys may take a few minutes to activate

### Unsplash API Key
1. Go to: https://unsplash.com/developers
2. Create a new application
3. Copy the Access Key

### OpenRouteService API Key
1. Go to: https://openrouteservice.org/dev/#/signup
2. Sign up and get your API key

## Testing the Weather API Key

The current key `a66f410cb7cdd3f1deda35cb2306b736` is returning a 401 error, which means:
- The key might not be activated yet (wait a few minutes after registration)
- The key might be invalid
- The key might have expired

**The app will continue to work with mock weather data**, but you'll need a valid key to get real weather information.

## After Adding/Updating Keys

1. Restart the Django server:
   ```bash
   python manage.py runserver
   ```
2. The new keys will be loaded automatically

## Current Behavior

- ❌ Weather API: Using mock data (key invalid)
- ❌ Unsplash API: Using placeholder images (no key)
- ❌ OpenRouteService API: Using mock route data (no key)
- ✅ Wikipedia API: Working (no key needed)
- ⚠️ Hotels API: Using mock data (requires Booking.com or TripAdvisor API)
- ⚠️ Ollama: Requires Ollama to be running locally

The app will work fine with mock data, but real API keys will provide better results!

