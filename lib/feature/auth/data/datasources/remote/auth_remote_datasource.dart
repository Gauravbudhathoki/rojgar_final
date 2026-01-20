
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/api/api_client.dart';
import 'package:rojgar/core/api/api_endpoints.dart';
import 'package:rojgar/core/services/storage/user_session_service.dart';
import 'package:rojgar/feature/auth/data/datasources/auth_datasource.dart';
import 'package:rojgar/feature/auth/data/models/auth_api_model.dart';
import 'package:rojgar/feature/auth/data/models/auth_hive_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getUserById(AuthHiveModel auth) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.user}/${auth.authId}',
      );
      final data = response.data;

      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic>) {
        return AuthApiModel.fromJson(data['user']);
      }
      return null;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message']
          : data?.toString();
      throw Exception(message ?? 'Failed to fetch user');
    }
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic>) {
        final user = AuthApiModel.fromJson(data['user']);

        await _userSessionService.saveUserSession(
          authId: user.id!,
          username : user.username,
          email: user.email,
          profileImage: user.profilePicture,
        );

        return user;
      }

      throw Exception('Invalid login response');
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message']
          : data?.toString();
      throw Exception(message ?? 'Login failed');
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'username': user.username,
          'email': user.email,
          'password': user.password,
        },
      );
      return user;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message']
          : data?.toString();
      throw Exception(message ?? 'Registration failed');
    }
  }
}