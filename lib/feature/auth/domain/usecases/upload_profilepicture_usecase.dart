import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/feature/auth/data/repositories/auth_repository.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/domain/repositories/auth_repository.dart';

final uploadProfilePictureUsecaseProvider =
    Provider<UploadProfilePictureUsecase>((ref) {
      return UploadProfilePictureUsecase(
        repository: ref.read(authRepositoryProvider),
      );
    });

class UploadProfilePictureUsecase {
  final IAuthRepository repository;

  UploadProfilePictureUsecase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(
    UploadProfilePictureUsecaseParams params,
  ) async {
    return await repository.uploadProfilePicture(
      params.imageFile,
      params.userId,
    );
  }
}

class UploadProfilePictureUsecaseParams extends Equatable {
  final File imageFile;
  final String userId;

  const UploadProfilePictureUsecaseParams({
    required this.imageFile,
    required this.userId,
  });

  @override
  List<Object?> get props => [imageFile, userId];
}