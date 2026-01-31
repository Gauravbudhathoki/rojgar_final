import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';


abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> uploadProfilePicture(
    File imageFile,
    String userId,
  );
}