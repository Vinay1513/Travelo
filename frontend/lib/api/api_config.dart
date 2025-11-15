class ApiConfig {
  // Change this to your Django backend URL
  // For Android Emulator: http://10.0.2.2:8000/api
  // For iOS Simulator: http://localhost:8000/api
  // For Real Device: http://YOUR_IP:8000/api (e.g., http://192.168.1.100:8000/api)

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Alternative URLs for different environments
  static const String localAndroid = 'http://10.0.2.2:8000/api';
  static const String localIOS = 'http://localhost:8000/api';

  // Production URL (when deployed)
  static const String production = 'https://your-production-url.com/api';

  // Endpoints
  static const String travelInfo = '/travel/info/';
  static const String restaurants = '/restaurants/';
  static const String hotels = '/hotels/';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
