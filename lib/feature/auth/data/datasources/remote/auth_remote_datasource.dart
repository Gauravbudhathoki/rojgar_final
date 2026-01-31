import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/api/api_client.dart';
import 'package:rojgar/core/api/api_endpoints.dart';
import 'package:rojgar/core/services/storage/token_service.dart';
import 'package:rojgar/core/services/storage/user_session_service.dart';
import 'package:rojgar/feature/auth/data/datasources/auth_datasource.dart';

import 'package:rojgar/feature/auth/data/models/auth_api_model.dart';
import 'package:rojgar/feature/auth/data/models/auth_hive_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

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
          email: user.email,
          username: user.username,
          profileImage: user.profilePicture,
        );

        final token = data['token'];
        await _tokenService.saveToken(token);

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
          'userName': user.username,
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

  @override
  Future<String> uploadProfilePicture(File photo, String userId) async {
    try {
      String fileName = photo.path.split('/').last;
      FormData formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          photo.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        '${ApiEndpoints.uploadProfilePicture}/$userId',
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['profilePicture'] != null) {
        return data['profilePicture'];
      }

      throw Exception('Failed to get profile picture URL');
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message']
          : data?.toString();
      throw Exception(message ?? 'Failed to upload profile picture');
    }
  }

  @override
  Future<AuthApiModel> updateProfilePicture(
    String userId,
    String profilePictureUrl,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.user}/$userId',
        data: {'profilePicture': profilePictureUrl},
      );

      final data = response.data;
      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic>) {
        final updatedUser = AuthApiModel.fromJson(data['user']);

        await _userSessionService.saveUserSession(
          authId: updatedUser.id!,
          email: updatedUser.email,
          username: updatedUser.username,
          profileImage: updatedUser.profilePicture,
        );

        return updatedUser;
      }

      throw Exception('Failed to update profile picture');
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message']
          : data?.toString();
      throw Exception(message ?? 'Failed to update profile picture');
    }
  }
}