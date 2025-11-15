# 🚀 Quick Start: Running Django Backend

## Step 1: Activate Virtual Environment
```powershell
# Navigate to backend folder
cd backend

# Activate virtual environment (Windows PowerShell)
.\venv\Scripts\Activate.ps1

# If you get execution policy error, run this first:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or use Command Prompt (cmd):
venv\Scripts\activate.bat
```

## Step 2: Install Dependencies
```powershell
pip install -r requirements.txt
```

## Step 3: Setup Environment Variables
The `.env` file should already be created. Edit it to add your API keys:
```env
SECRET_KEY=django-insecure-change-this-in-production-xyz123
UNSPLASH_ACCESS_KEY=your-unsplash-key-here
OPENWEATHER_API_KEY=your-openweather-key-here
OPENROUTESERVICE_API_KEY=your-openrouteservice-key-here
OLLAMA_BASE_URL=http://localhost:11434
```

**Note**: You can run without API keys - the app will use mock data for missing services.

## Step 4: Run Migrations
```powershell
python manage.py migrate
```

## Step 5: Start Server
```powershell
python manage.py runserver
```

✅ Server will run on: **http://127.0.0.1:8000/**

## Test the API
Open Postman or browser and test:
```
POST http://localhost:8000/api/travel/info/
Content-Type: application/json

{
  "place": "Pune",
  "user_location": "Mumbai"
}
```

## Troubleshooting

### If Django is not found:
```powershell
pip install Django==4.2.7 djangorestframework
```

### If port 8000 is busy:
```powershell
python manage.py runserver 8001
```

### To stop server:
Press `Ctrl+C` in the terminal

