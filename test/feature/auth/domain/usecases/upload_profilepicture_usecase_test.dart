import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/domain/repositories/auth_repository.dart';
import 'package:rojgar/feature/auth/domain/usecases/upload_profilepicture_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockFile extends Mock implements File {}

void main() {
  late UploadProfilePictureUsecase usecase;
  late MockAuthRepository mockRepository;
  late MockFile mockFile;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockFile = MockFile();
    usecase = UploadProfilePictureUsecase(repository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  const tUserId = '123';
  final tParams = UploadProfilePictureUsecaseParams(
    imageFile: MockFile(),
    userId: tUserId,
  );

  const tAuthEntity = AuthEntity(
    authId: tUserId,
    username: 'Test User',
    email: 'test@example.com',
    password: 'password123',
    profilePicture: 'https://example.com/profile.jpg',
  );

  group('UploadProfilePictureUsecase', () {
    test('should return AuthEntity when upload is successful', () async {
      // Arrange
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(tAuthEntity));
      verify(
        () => mockRepository.uploadProfilePicture(any(), tUserId),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct file and userId to repository', () async {
      // Arrange
      File? capturedFile;
      String? capturedUserId;
      when(() => mockRepository.uploadProfilePicture(any(), any())).thenAnswer((
        invocation,
      ) {
        capturedFile = invocation.positionalArguments[0] as File;
        capturedUserId = invocation.positionalArguments[1] as String;
        return Future.value(const Right(tAuthEntity));
      });

      // Act
      await usecase(tParams);

      // Assert
      expect(capturedFile, isNotNull);
      expect(capturedUserId, tUserId);
    });

    test('should return AuthEntity with updated profile picture', () async {
      // Arrange
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase(tParams);

      // Assert
      result.fold((failure) => fail('Should return AuthEntity'), (entity) {
        expect(entity.profilePicture, 'https://example.com/profile.jpg');
        expect(entity.authId, tUserId);
        expect(entity.username, 'Test User');
      });
    });

    test('should return ApiFailure when upload fails', () async {
      // Arrange
      const tFailure = ApiFailure(
        message: 'Failed to upload image',
        statusCode: 500,
      );
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(
        () => mockRepository.uploadProfilePicture(any(), tUserId),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when file is too large', () async {
      // Arrange
      const tFailure = ApiFailure(
        message: 'File size exceeds limit',
        statusCode: 413,
      );
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ApiFailure>());
        expect((failure as ApiFailure).message, 'File size exceeds limit');
        expect(failure.statusCode, 413);
      }, (_) => fail('Should return failure'));
    });

    test('should return ApiFailure when file format is invalid', () async {
      // Arrange
      const tFailure = ApiFailure(
        message: 'Invalid file format',
        statusCode: 400,
      );
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ApiFailure>());
        expect((failure as ApiFailure).message, 'Invalid file format');
      }, (_) => fail('Should return failure'));
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        const tFailure = NetworkFailure();
        when(
          () => mockRepository.uploadProfilePicture(any(), any()),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockRepository.uploadProfilePicture(any(), tUserId),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ApiFailure when user not found', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'User not found', statusCode: 404);
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ApiFailure>());
        expect((failure as ApiFailure).message, 'User not found');
        expect(failure.statusCode, 404);
      }, (_) => fail('Should return failure'));
    });

    test('should call repository only once', () async {
      // Arrange
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      await usecase(tParams);

      // Assert
      verify(
        () => mockRepository.uploadProfilePicture(any(), tUserId),
      ).called(1);
    });

    test('should handle upload with different user IDs', () async {
      // Arrange
      const differentUserId = '456';
      final differentParams = UploadProfilePictureUsecaseParams(
        imageFile: MockFile(),
        userId: differentUserId,
      );
      const differentAuthEntity = AuthEntity(
        authId: differentUserId,
        username: 'Different User',
        email: 'different@example.com',
        profilePicture: 'https://example.com/different.jpg',
      );
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Right(differentAuthEntity));

      // Act
      final result = await usecase(differentParams);

      // Assert
      result.fold((failure) => fail('Should return AuthEntity'), (entity) {
        expect(entity.authId, differentUserId);
        expect(entity.profilePicture, 'https://example.com/different.jpg');
      });
      verify(
        () => mockRepository.uploadProfilePicture(any(), differentUserId),
      ).called(1);
    });

    test('should return LocalDatabaseFailure when offline upload fails',
        () async {
      // Arrange
      const tFailure = LocalDatabaseFailure(
        message: 'Failed to save profile picture locally',
      );
      when(
        () => mockRepository.uploadProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(
        () => mockRepository.uploadProfilePicture(any(), tUserId),
      ).called(1);
    });
  });

  group('UploadProfilePictureUsecaseParams', () {
    test('should have correct props', () {
      // Arrange
      final params = UploadProfilePictureUsecaseParams(
        imageFile: mockFile,
        userId: tUserId,
      );

      // Assert
      expect(params.props, [mockFile, tUserId]);
    });

    test('two params with same values should be equal', () {
      // Arrange
      final params1 = UploadProfilePictureUsecaseParams(
        imageFile: mockFile,
        userId: tUserId,
      );
      final params2 = UploadProfilePictureUsecaseParams(
        imageFile: mockFile,
        userId: tUserId,
      );

      // Assert
      expect(params1, params2);
    });

    test('two params with different userId should not be equal', () {
      // Arrange
      final params1 = UploadProfilePictureUsecaseParams(
        imageFile: mockFile,
        userId: tUserId,
      );
      final params2 = UploadProfilePictureUsecaseParams(
        imageFile: mockFile,
        userId: '456',
      );

      // Assert
      expect(params1, isNot(params2));
    });

    test('two params with different file should not be equal', () {
      // Arrange
      final mockFile2 = MockFile();
      final params1 = UploadProfilePictureUsecaseParams(
        imageFile: mockFile,
        userId: tUserId,
      );
      final params2 = UploadProfilePictureUsecaseParams(
        imageFile: mockFile2,
        userId: tUserId,
      );

      // Assert
      expect(params1, isNot(params2));
    });

    test('params should contain both imageFile and userId', () {
      // Arrange
      final params = UploadProfilePictureUsecaseParams(
        imageFile: mockFile,
        userId: tUserId,
      );

      // Assert
      expect(params.imageFile, mockFile);
      expect(params.userId, tUserId);
    });
  });
}