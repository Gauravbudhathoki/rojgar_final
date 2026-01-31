import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rojgar/core/error/failures.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/domain/repositories/auth_repository.dart';
import 'package:rojgar/feature/auth/domain/usecases/regester_usecase.dart';


class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        username: 'fallback',
        email: 'fallback@example.com',
        password: 'fallback',
      ),
    );
  });

  const tUsername = 'TestUser';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tParams = RegisterUsecaseParams(
    username: tUsername,
    email: tEmail,
    password: tPassword,
  );

  group('RegisterUsecase', () {
    test('should return true when registration is successful', () async {
      // Arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass AuthEntity with correct data to repository', () async {
      // Arrange
      AuthEntity? capturedEntity;
      when(() => mockRepository.register(any())).thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      // Act
      await usecase(tParams);

      // Assert
      expect(capturedEntity, isNotNull);
      expect(capturedEntity?.username, tUsername);
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.password, tPassword);
    });

    test('should return ApiFailure when email already exists', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when registration fails', () async {
      // Arrange
      const tFailure = ApiFailure(
        message: 'Registration failed',
        statusCode: 400,
      );
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ApiFailure>());
        expect((failure as ApiFailure).message, 'Registration failed');
        expect(failure.statusCode, 400);
      }, (_) => fail('Should return failure'));
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        const tFailure = NetworkFailure();
        when(
          () => mockRepository.register(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockRepository.register(any())).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return LocalDatabaseFailure when offline registration fails',
      () async {
        // Arrange
        const tFailure = LocalDatabaseFailure(
          message: 'Failed to save user locally',
        );
        when(
          () => mockRepository.register(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockRepository.register(any())).called(1);
      },
    );

    test('should call repository only once for valid data', () async {
      // Arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await usecase(tParams);

      // Assert
      verify(() => mockRepository.register(any())).called(1);
    });

    test('should handle registration with all valid fields', () async {
      // Arrange
      const tCompleteParams = RegisterUsecaseParams(
        username: 'John Doe',
        email: 'john.doe@example.com',
        password: 'SecurePass123!',
      );
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tCompleteParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
    });

    test('should create AuthEntity without authId', () async {
      // Arrange
      AuthEntity? capturedEntity;
      when(() => mockRepository.register(any())).thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      // Act
      await usecase(tParams);

      // Assert
      expect(capturedEntity?.authId, isNull);
      expect(capturedEntity?.username, tUsername);
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.password, tPassword);
    });

    test('should handle username with spaces', () async {
      // Arrange
      const tParamsWithSpaces = RegisterUsecaseParams(
        username: 'John Doe Smith',
        email: 'john@example.com',
        password: 'password123',
      );
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParamsWithSpaces);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
    });

    test('should handle long username', () async {
      // Arrange
      const tParamsLongUsername = RegisterUsecaseParams(
        username: 'This is a very long username for testing purposes',
        email: 'longusername@example.com',
        password: 'password123',
      );
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParamsLongUsername);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
    });
  });

  group('RegisterUsecaseParams', () {
    test('should have correct props', () {
      // Arrange
      const params = RegisterUsecaseParams(
        username: tUsername,
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(params.props, [tUsername, tEmail, tPassword]);
    });

    test('two params with same values should be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        username: tUsername,
        email: tEmail,
        password: tPassword,
      );
      const params2 = RegisterUsecaseParams(
        username: tUsername,
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        username: tUsername,
        email: tEmail,
        password: tPassword,
      );
      const params2 = RegisterUsecaseParams(
        username: 'Different Name',
        email: 'different@example.com',
        password: 'different123',
      );

      // Assert
      expect(params1, isNot(params2));
    });

    test('params with different username should not be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        username: 'User1',
        email: tEmail,
        password: tPassword,
      );
      const params2 = RegisterUsecaseParams(
        username: 'User2',
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(params1, isNot(params2));
    });

    test('params with different email should not be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        username: tUsername,
        email: 'email1@example.com',
        password: tPassword,
      );
      const params2 = RegisterUsecaseParams(
        username: tUsername,
        email: 'email2@example.com',
        password: tPassword,
      );

      // Assert
      expect(params1, isNot(params2));
    });

    test('params with different password should not be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        username: tUsername,
        email: tEmail,
        password: 'password1',
      );
      const params2 = RegisterUsecaseParams(
        username: tUsername,
        email: tEmail,
        password: 'password2',
      );

      // Assert
      expect(params1, isNot(params2));
    });
  });
}