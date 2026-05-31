import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());
final authServiceProvider = Provider<AuthService>((ref) => AuthService(
    ref.watch(apiClientProvider), ref.watch(storageServiceProvider)));
