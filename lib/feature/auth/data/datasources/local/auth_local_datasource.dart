import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/services/hive/hive_service.dart';
import 'package:rojgar/core/services/storage/user_session_service.dart';
import 'package:rojgar/feature/auth/data/datasources/auth_datasource.dart';
import 'package:rojgar/feature/auth/data/models/auth_hive_model.dart';

//Provider
final authLocalDatasourceProvider = Provider<IAuthLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  // ignore: non_constant_identifier_names
  final UserSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: UserSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.login(email, password);
      //user ko details lai shared preferences ma save garne
      if (user != null) {
        await _userSessionService.saveUserSession(
          authId: user.authId!,
          email: user.email,
          username: user.username,
          profileImage: user.profilePicture,
        );
      }
      return user;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logout();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return Future.value(true);
    } catch (e) {
      // Re-throw the exception to be handled by the repository
      rethrow;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel model) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}