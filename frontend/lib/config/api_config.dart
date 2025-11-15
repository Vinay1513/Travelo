import 'dart:io';

class ApiConfig {
  // Get the base URL based on the platform
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return 'http://localhost:8000/api';
    } else {
      // For web, Windows, Linux, macOS - use localhost
      return 'http://localhost:8000/api';
    }
  }
  
  // For physical devices, you'll need to use your computer's IP address
  // Example: 'http://192.168.1.100:8000/api'
  // Uncomment and update this if testing on a physical device:
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000/api';
}

