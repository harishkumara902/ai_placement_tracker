import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthController extends ChangeNotifier {
  final ApiClient api = ApiClient();
  Map<String, dynamic>? user;
  bool initializing = true;
  bool busy = false;

  bool get authenticated => user != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('placement_token');
    if (token != null) {
      api.setToken(token);
      try {
        final response = await api.dio.get('/auth/me');
        user = Map<String, dynamic>.from(response.data);
      } catch (_) {
        await prefs.remove('placement_token');
        api.setToken(null);
      }
    }
    initializing = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    return _authenticate('/auth/login', {'email': email, 'password': password});
  }

  Future<String?> register(String name, String email, String password) async {
    return _authenticate('/auth/register', {
      'full_name': name,
      'email': email,
      'password': password,
    });
  }

  Future<String?> _authenticate(
    String endpoint,
    Map<String, dynamic> values,
  ) async {
    busy = true;
    notifyListeners();
    try {
      final response = await api.dio.post(endpoint, data: values);
      final token = response.data['access_token'] as String;
      user = Map<String, dynamic>.from(response.data['user']);
      api.setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('placement_token', token);
      return null;
    } catch (error) {
      return api.errorMessage(error);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('placement_token');
    api.setToken(null);
    user = null;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AuthController> {
  const AppScope({
    required AuthController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }
}
