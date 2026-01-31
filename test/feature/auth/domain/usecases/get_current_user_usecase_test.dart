import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/domain/repositories/auth_repository.dart';
import 'package:rojgar/feature/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUserUsecase(repository: mockRepository);
  });

  const tAuthEntity = AuthEntity(
    authId: '123',
    username: 'Test User',
    email: 'test@example.com',
    password: 'password123',
  );

  group('GetCurrentUserUsecase', () {
    test(
      'should return AuthEntity when user is retrieved successfully',
      () async {
        // Arrange
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Right(tAuthEntity));

        // Act
        final result = await usecase();

        // Assert
        expect(result, const Right(tAuthEntity));
        verify(() => mockRepository.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return correct user data from repository', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase();

      // Assert
      result.fold((failure) => fail('Should return AuthEntity'), (entity) {
        expect(entity.authId, tAuthEntity.authId);
        expect(entity.username, tAuthEntity.username);
        expect(entity.email, tAuthEntity.email);
        expect(entity.password, tAuthEntity.password);
      });
    });

    test(
      'should return LocalDatabaseFailure when no user is logged in',
      () async {
        // Arrange
        const tFailure = LocalDatabaseFailure(message: 'No user logged in');
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase();

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockRepository.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return LocalDatabaseFailure when database error occurs',
      () async {
        // Arrange
        const tFailure = LocalDatabaseFailure(message: 'Database error');
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase();

        // Assert
        expect(result, const Left(tFailure));
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<LocalDatabaseFailure>());
          expect((failure as LocalDatabaseFailure).message, 'Database error');
        }, (_) => fail('Should return failure'));
      },
    );

    test('should return ApiFailure when server error occurs', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Server error', statusCode: 500);
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(tFailure));
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ApiFailure>());
        expect((failure as ApiFailure).message, 'Server error');
        expect(failure.statusCode, 500);
      }, (_) => fail('Should return failure'));
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        const tFailure = NetworkFailure();
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase();

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockRepository.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should call repository only once', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      await usecase();

      // Assert
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should handle user with profile picture', () async {
      // Arrange
      const tAuthEntityWithImage = AuthEntity(
        authId: '123',
        username: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        profilePicture: 'https://example.com/profile.jpg',
      );
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tAuthEntityWithImage));

      // Act
      final result = await usecase();

      // Assert
      result.fold((failure) => fail('Should return AuthEntity'), (entity) {
        expect(entity.profilePicture, 'https://example.com/profile.jpg');
      });
    });

    test('should handle user without optional fields', () async {
      // Arrange
      const tMinimalAuthEntity = AuthEntity(
        username: 'Test User',
        email: 'test@example.com',
      );
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tMinimalAuthEntity));

      // Act
      final result = await usecase();

      // Assert
      result.fold((failure) => fail('Should return AuthEntity'), (entity) {
        expect(entity.authId, isNull);
        expect(entity.password, isNull);
        expect(entity.profilePicture, isNull);
        expect(entity.username, 'Test User');
        expect(entity.email, 'test@example.com');
      });
    });

    test('should handle user with all fields populated', () async {
      // Arrange
      const tCompleteAuthEntity = AuthEntity(
        authId: '123',
        username: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        profilePicture: 'https://example.com/profile.jpg',
      );
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tCompleteAuthEntity));

      // Act
      final result = await usecase();

      // Assert
      result.fold((failure) => fail('Should return AuthEntity'), (entity) {
        expect(entity.authId, '123');
        expect(entity.username, 'Test User');
        expect(entity.email, 'test@example.com');
        expect(entity.password, 'password123');
        expect(entity.profilePicture, 'https://example.com/profile.jpg');
      });
    });
  });
}