import 'package:dio/dio.dart';

import '../core/api_client.dart';

class ApiService {
  ApiService(this.client);

  final ApiClient client;

  Future<Response<dynamic>> get(String path) => client.dio.get(path);

  Future<Response<dynamic>> post(String path, {Object? data}) =>
      client.dio.post(path, data: data);
}
