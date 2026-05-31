import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  Future<String?> readToken() => _storage.read(key: ApiConfig.tokenKey);

  Future<void> writeToken(String token) =>
      _storage.write(key: ApiConfig.tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: ApiConfig.tokenKey);
}
