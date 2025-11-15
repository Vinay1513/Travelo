# Frontend - Travel Assistant Flutter App

Beautiful Flutter app for the Travel Assistant.

## Setup Instructions

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Generate code for JSON serialization and API client:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Update API base URL in `lib/api/api_client.dart`:
   - For Android Emulator: `http://10.0.2.2:8000/api`
   - For iOS Simulator: `http://localhost:8000/api`
   - For Physical Device: `http://YOUR_COMPUTER_IP:8000/api`

4. Run the app:
   ```bash
   flutter run
   ```

## Features

- Modern UI with smooth animations
- Place search and details
- Weather information
- Route planning
- Hotel recommendations
- AI chat assistant
- Top tourist spots
- Pull-to-refresh

