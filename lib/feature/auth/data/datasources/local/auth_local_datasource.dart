import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/services/hive/hive_service.dart';
import 'package:rojgar/feature/auth/data/datasources/auth_datasource.dart';
import 'package:rojgar/feature/auth/data/models/auth_hive_model.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  // ignore: unnecessary_null_comparison
  assert(hiveService != null, 'HiveService not initialized');
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return null; // implement when session logic is added
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return _hiveService.isEmailExists(email);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    return _hiveService.login(email, password);
  }

  @override
  Future<bool> logout() async {
    await _hiveService.logout();
    return true;
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    await _hiveService.registerUser(model);
    return true;
  }
}
