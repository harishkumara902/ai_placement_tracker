class ApiConfig {
  // Change this after Render deployment.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-app-name.onrender.com',
  );

  // Local Android emulator:
  // static const String baseUrl = 'http://10.0.2.2:8000';
  // iOS simulator:
  // static const String baseUrl = 'http://localhost:8000';

  static const Duration timeout = Duration(seconds: 30);
  static const String tokenKey = 'auth_token';
}
