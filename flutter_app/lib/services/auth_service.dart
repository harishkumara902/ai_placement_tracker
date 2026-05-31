import '../core/api_client.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this.api, this.storage);

  final ApiClient api;
  final StorageService storage;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await api.dio
        .post('/auth/login', data: {'email': email, 'password': password});
    final token = response.data['access_token'] as String;
    await storage.writeToken(token);
    api.setToken(token);
    return Map<String, dynamic>.from(response.data['user']);
  }

  Future<void> logout() async {
    await storage.clearToken();
    api.setToken(null);
  }
}
