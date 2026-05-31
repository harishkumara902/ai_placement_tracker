import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({String? token})
      : dio = Dio(
          BaseOptions(
            baseUrl: const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://127.0.0.1:8000/api',
            ),
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 30),
            headers: token == null ? null : {'Authorization': 'Bearer $token'},
          ),
        );

  final Dio dio;

  void setToken(String? token) {
    if (token == null) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  String errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      return error.message ?? 'Unable to connect to the mentor service.';
    }
    return 'Something went wrong. Please try again.';
  }
}
