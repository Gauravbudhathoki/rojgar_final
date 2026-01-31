import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/feature/auth/data/repositories/auth_repository.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/domain/repositories/auth_repository.dart';

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(repository: ref.read(authRepositoryProvider));
});

class GetCurrentUserUsecase {
  final IAuthRepository repository;

  GetCurrentUserUsecase({required this.repository});

  Future<Either<Failure, AuthEntity>> call() async {
    return await repository.getCurrentUser();
  }
}