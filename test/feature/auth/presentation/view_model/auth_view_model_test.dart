import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:rojgar/feature/auth/domain/usecases/login_usecase.dart';
import 'package:rojgar/feature/auth/domain/usecases/regester_usecase.dart';
import 'package:rojgar/feature/auth/domain/usecases/upload_profilepicture_usecase.dart';
import 'package:rojgar/feature/auth/presentation/state/auth_state.dart';
import 'package:rojgar/feature/auth/presentation/view_model/auth_view_model.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockUploadProfilePictureUsecase extends Mock
    implements UploadProfilePictureUsecase {}

class MockFile extends Mock implements File {}

void main() {
  late AuthViewModel viewModel;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockUploadProfilePictureUsecase mockUploadProfilePictureUsecase;
  late ProviderContainer container;

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockUploadProfilePictureUsecase = MockUploadProfilePictureUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        uploadProfilePictureUsecaseProvider.overrideWithValue(
          mockUploadProfilePictureUsecase,
        ),
      ],
    );

    viewModel = container.read(authViewModelProvider.notifier);
  });

  setUpAll(() {
    registerFallbackValue(
      const RegisterUsecaseParams(
        username: 'fallback',
        email: 'fallback@example.com',
        password: 'fallback',
      ),
    );
    registerFallbackValue(
      const LoginUsecaseParams(
        email: 'fallback@example.com',
        password: 'fallback',
      ),
    );
    registerFallbackValue(
      UploadProfilePictureUsecaseParams(
        imageFile: MockFile(),
        userId: 'fallback',
      ),
    );
  });

  tearDown(() {
    container.dispose();
  });

  const tAuthEntity = AuthEntity(
    authId: '123',
    username: 'Test User',
    email: 'test@example.com',
    password: 'password123',
  );

  group('AuthViewModel - Initial State', () {
    test('initial state should be AuthStatus.initial', () {
      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.authEntity, isNull);
      expect(state.errorMessage, isNull);
    });
  });

  group('AuthViewModel - Register', () {
    const tUsername = 'Test User';
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test(
      'should emit loading then registered on successful registration',
      () async {
        // Arrange
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final future = viewModel.register(
          username: tUsername,
          email: tEmail,
          password: tPassword,
        );

        // Assert - loading state
        expect(
          container.read(authViewModelProvider).status,
          AuthStatus.loading,
        );

        await future;

        // Assert - registered state
        expect(
          container.read(authViewModelProvider).status,
          AuthStatus.registered,
        );
        verify(() => mockRegisterUsecase(any())).called(1);
      },
    );

    test('should emit loading then error on registration failure', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final future = viewModel.register(
        username: tUsername,
        email: tEmail,
        password: tPassword,
      );

      // Assert - loading state
      expect(container.read(authViewModelProvider).status, AuthStatus.loading);

      await future;

      // Assert - error state
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Email already exists');
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('should pass correct params to register usecase', () async {
      // Arrange
      RegisterUsecaseParams? capturedParams;
      when(() => mockRegisterUsecase(any())).thenAnswer((invocation) {
        capturedParams =
            invocation.positionalArguments[0] as RegisterUsecaseParams;
        return Future.value(const Right(true));
      });

      // Act
      await viewModel.register(
        username: tUsername,
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(capturedParams?.username, tUsername);
      expect(capturedParams?.email, tEmail);
      expect(capturedParams?.password, tPassword);
    });

    test('should handle network failure during registration', () async {
      // Arrange
      const tFailure = NetworkFailure();
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.register(
        username: tUsername,
        email: tEmail,
        password: tPassword,
      );

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'No internet connection');
    });

    test('should handle local database failure during registration', () async {
      // Arrange
      const tFailure = LocalDatabaseFailure(message: 'Database error');
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.register(
        username: tUsername,
        email: tEmail,
        password: tPassword,
      );

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Database error');
    });
  });

  group('AuthViewModel - Login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test(
      'should emit loading then authenticated on successful login',
      () async {
        // Arrange
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Right(tAuthEntity));

        // Act
        final future = viewModel.login(email: tEmail, password: tPassword);

        // Assert - loading state
        expect(
          container.read(authViewModelProvider).status,
          AuthStatus.loading,
        );

        await future;

        // Assert - authenticated state
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.authEntity, tAuthEntity);
        verify(() => mockLoginUsecase(any())).called(1);
      },
    );

    test('should emit loading then error on login failure', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Invalid email or password');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final future = viewModel.login(email: tEmail, password: tPassword);

      // Assert - loading state
      expect(container.read(authViewModelProvider).status, AuthStatus.loading);

      await future;

      // Assert - error state
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid email or password');
      verify(() => mockLoginUsecase(any())).called(1);
    });

    test('should pass correct params to login usecase', () async {
      // Arrange
      LoginUsecaseParams? capturedParams;
      when(() => mockLoginUsecase(any())).thenAnswer((invocation) {
        capturedParams =
            invocation.positionalArguments[0] as LoginUsecaseParams;
        return Future.value(const Right(tAuthEntity));
      });

      // Act
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      expect(capturedParams?.email, tEmail);
      expect(capturedParams?.password, tPassword);
    });

    test('should handle network failure during login', () async {
      // Arrange
      const tFailure = NetworkFailure();
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'No internet connection');
    });

    test('should handle local database failure during login', () async {
      // Arrange
      const tFailure = LocalDatabaseFailure(message: 'Database error');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Database error');
    });
  });

  group('AuthViewModel - Get Current User', () {
    test('should emit loading then authenticated when user exists', () async {
      // Arrange
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final future = viewModel.getCurrentUser();

      // Assert - loading state
      expect(container.read(authViewModelProvider).status, AuthStatus.loading);

      await future;

      // Assert - authenticated state
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.authEntity, tAuthEntity);
      verify(() => mockGetCurrentUserUsecase()).called(1);
    });

    test('should emit loading then error when no user is logged in', () async {
      // Arrange
      const tFailure = LocalDatabaseFailure(message: 'No user logged in');
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final future = viewModel.getCurrentUser();

      // Assert - loading state
      expect(container.read(authViewModelProvider).status, AuthStatus.loading);

      await future;

      // Assert - error state
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'No user logged in');
      verify(() => mockGetCurrentUserUsecase()).called(1);
    });

    test('should handle database error when getting current user', () async {
      // Arrange
      const tFailure = LocalDatabaseFailure(message: 'Database error');
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.getCurrentUser();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Database error');
    });

    test('should handle API failure when getting current user', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Server error', statusCode: 500);
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.getCurrentUser();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Server error');
    });

    test('should handle network failure when getting current user', () async {
      // Arrange
      const tFailure = NetworkFailure();
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.getCurrentUser();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'No internet connection');
    });
  });

  group('AuthViewModel - Upload Profile Picture', () {
    final mockFile = MockFile();

    test(
      'should emit loading then authenticated on successful upload',
      () async {
        // Arrange
        const tUpdatedAuthEntity = AuthEntity(
          authId: '123',
          username: 'Test User',
          email: 'test@example.com',
          password: 'password123',
          profilePicture: 'https://example.com/profile.jpg',
        );

        // Set initial state with logged in user
        container.read(authViewModelProvider.notifier).state = const AuthState(
          status: AuthStatus.authenticated,
          authEntity: tAuthEntity,
        );

        when(
          () => mockUploadProfilePictureUsecase(any()),
        ).thenAnswer((_) async => const Right(tUpdatedAuthEntity));

        // Act
        final future = viewModel.uploadProfilePicture(mockFile);

        // Assert - loading state
        expect(
          container.read(authViewModelProvider).status,
          AuthStatus.loading,
        );

        await future;

        // Assert - authenticated state with updated entity
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(
          state.authEntity?.profilePicture,
          'https://example.com/profile.jpg',
        );
        verify(() => mockUploadProfilePictureUsecase(any())).called(1);
      },
    );

    test('should emit error when user is not logged in', () async {
      // Arrange - no user in state
      container.read(authViewModelProvider.notifier).state = const AuthState(
        status: AuthStatus.initial,
      );

      // Act
      await viewModel.uploadProfilePicture(mockFile);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'User not logged in');
      verifyNever(() => mockUploadProfilePictureUsecase(any()));
    });

    test('should emit error on upload failure', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Failed to upload image');

      // Set initial state with logged in user
      container.read(authViewModelProvider.notifier).state = const AuthState(
        status: AuthStatus.authenticated,
        authEntity: tAuthEntity,
      );

      when(
        () => mockUploadProfilePictureUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.uploadProfilePicture(mockFile);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Failed to upload image');
    });

    test('should pass correct params to upload usecase', () async {
      // Arrange
      UploadProfilePictureUsecaseParams? capturedParams;

      // Set initial state with logged in user
      container.read(authViewModelProvider.notifier).state = const AuthState(
        status: AuthStatus.authenticated,
        authEntity: tAuthEntity,
      );

      when(() => mockUploadProfilePictureUsecase(any())).thenAnswer((
        invocation,
      ) {
        capturedParams =
            invocation.positionalArguments[0]
                as UploadProfilePictureUsecaseParams;
        return Future.value(const Right(tAuthEntity));
      });

      // Act
      await viewModel.uploadProfilePicture(mockFile);

      // Assert
      expect(capturedParams?.imageFile, mockFile);
      expect(capturedParams?.userId, '123');
    });

    test('should handle network failure during upload', () async {
      // Arrange
      const tFailure = NetworkFailure();

      // Set initial state with logged in user
      container.read(authViewModelProvider.notifier).state = const AuthState(
        status: AuthStatus.authenticated,
        authEntity: tAuthEntity,
      );

      when(
        () => mockUploadProfilePictureUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.uploadProfilePicture(mockFile);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'No internet connection');
    });

    test('should handle file size error during upload', () async {
      // Arrange
      const tFailure = ApiFailure(
        message: 'File size exceeds limit',
        statusCode: 413,
      );

      // Set initial state with logged in user
      container.read(authViewModelProvider.notifier).state = const AuthState(
        status: AuthStatus.authenticated,
        authEntity: tAuthEntity,
      );

      when(
        () => mockUploadProfilePictureUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.uploadProfilePicture(mockFile);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'File size exceeds limit');
    });

    test('should handle invalid file format during upload', () async {
      // Arrange
      const tFailure = ApiFailure(
        message: 'Invalid file format',
        statusCode: 400,
      );

      // Set initial state with logged in user
      container.read(authViewModelProvider.notifier).state = const AuthState(
        status: AuthStatus.authenticated,
        authEntity: tAuthEntity,
      );

      when(
        () => mockUploadProfilePictureUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.uploadProfilePicture(mockFile);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid file format');
    });
  });
}