# Django Backend Setup Guide

## Step-by-Step Instructions

### 1. Navigate to Backend Directory
```bash
cd backend
```

### 2. Create Virtual Environment (if not already created)
```bash
# Windows PowerShell
python -m venv venv

# Activate it
.\venv\Scripts\activate

# For Command Prompt (cmd)
venv\Scripts\activate.bat

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Create .env File
Create a file named `.env` in the `backend` directory with the following content:

```env
SECRET_KEY=django-insecure-change-this-in-production-xyz123
UNSPLASH_ACCESS_KEY=your-unsplash-access-key-here
OPENWEATHER_API_KEY=your-openweather-api-key-here
OPENROUTESERVICE_API_KEY=your-openrouteservice-api-key-here
OLLAMA_BASE_URL=http://localhost:11434
```

**Get API Keys:**
- **Unsplash**: https://unsplash.com/developers
- **OpenWeatherMap**: https://openweathermap.org/api
- **OpenRouteService**: https://openrouteservice.org/dev/#/signup

**Note**: You can run without API keys, but features will use mock data.

### 5. Run Migrations
```bash
python manage.py migrate
```

### 6. Start Django Server
```bash
python manage.py runserver
```

The server will run on: **http://127.0.0.1:8000/**

### 7. Test the API
Open browser or use curl/Postman:
```
POST http://localhost:8000/api/travel/info/
Content-Type: application/json

{
  "place": "Pune",
  "user_location": "Mumbai"
}
```

## Troubleshooting

### If Django is not installed:
```bash
pip install Django==4.2.7
```

### If you see "ModuleNotFoundError":
Make sure virtual environment is activated and dependencies are installed.

### If CORS errors occur:
The settings already allow CORS for development. For production, update `ALLOWED_HOSTS` in `settings.py`.

### If Ollama connection fails:
1. Install Ollama: https://ollama.ai
2. Start Ollama: `ollama serve`
3. Pull model: `ollama pull llama3.1`
4. Verify in `.env`: `OLLAMA_BASE_URL=http://localhost:11434`

