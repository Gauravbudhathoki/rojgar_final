import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/core/usecase/app.usecase.dart';
import 'package:rojgar/feature/auth/data/repositories/auth_repository.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/domain/repositories/auth_repository.dart';


class RegisterUsecaseParams extends Equatable {
  final String username;
  final String email;
  final String password;

  const RegisterUsecaseParams({
    required this.username,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [username, email, password];
}

//provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});



class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      username: params.username,
      email: params.email,
      password: params.password,
    );
    return _authRepository.register(entity);
  }
}