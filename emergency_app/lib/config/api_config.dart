class ApiConfig {
  // Use appropriate URL based on platform:
  // - Linux/Windows/macOS Desktop: 'http://localhost:8000'
  // - Android Emulator: 'http://10.0.2.2:8000'
  // - Physical device (same network): 'http://192.168.8.50:8000'
  static const String baseUrl = 'http://localhost:8000';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}