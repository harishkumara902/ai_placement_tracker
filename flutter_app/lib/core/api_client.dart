import 'package:dio/dio.dart';

import '../config/api_config.dart';

class ApiClient {
  ApiClient({String? token})
      : dio = Dio(
          BaseOptions(
            baseUrl: '${ApiConfig.baseUrl}/api',
            connectTimeout: ApiConfig.timeout,
            receiveTimeout: ApiConfig.timeout,
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
