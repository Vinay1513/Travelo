# Backend - Travel Assistant API

Django REST API for the Travel Assistant app.

## Setup Instructions

1. Create virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create `.env` file from `.env.example`:
   ```bash
   cp .env.example .env
   ```

4. Add your API keys to `.env` file

5. Run migrations:
   ```bash
   python manage.py migrate
   ```

6. Start server:
   ```bash
   python manage.py runserver
   ```

## API Endpoints

- `POST /api/travel/info/` - Get comprehensive travel information

## Environment Variables

- `UNSPLASH_ACCESS_KEY` - Unsplash API key
- `OPENWEATHER_API_KEY` - OpenWeatherMap API key
- `OPENROUTESERVICE_API_KEY` - OpenRouteService API key
- `OLLAMA_BASE_URL` - Ollama base URL (default: http://localhost:11434)

