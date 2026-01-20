import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/core/services/connectivity/network_info.dart';
import 'package:rojgar/feature/auth/data/datasources/auth_datasource.dart';
import 'package:rojgar/feature/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:rojgar/feature/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:rojgar/feature/auth/data/models/auth_api_model.dart';
import 'package:rojgar/feature/auth/data/models/auth_hive_model.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/domain/repositories/auth_repository.dart';
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authDatasource: ref.read(authLocalDatasourceProvider),
    authRemoteDataSource: ref.read(authRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDatasource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      }
      return Left(LocalDatabaseFailure(message: 'No user logged in'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }
        return const Left(ApiFailure(message: 'Invalid credentials'));
      } on DioException catch (e) {
        final data = e.response?.data;
        final message = data is Map<String, dynamic>
            ? data['message'] ?? 'Login failed'
            : data?.toString() ?? 'Login failed';

        return Left(
          ApiFailure(message: message, statusCode: e.response?.statusCode),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localModel = await _authDatasource.login(email, password);
        if (localModel != null) {
          return Right(localModel.toEntity());
        }
        return const Left(
          LocalDatabaseFailure(message: 'Invalid email or password'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(entity);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        final data = e.response?.data;
        final message = data is Map<String, dynamic>
            ? data['message'] ?? 'Registration failed'
            : data?.toString() ?? 'Registration failed';

        return Left(
          ApiFailure(message: message, statusCode: e.response?.statusCode),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localModel = AuthHiveModel.fromEntity(entity);
        await _authDatasource.register(localModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}