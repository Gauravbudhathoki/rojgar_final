import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/feature/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:rojgar/feature/auth/domain/usecases/login_usecase.dart';
import 'package:rojgar/feature/auth/domain/usecases/regester_usecase.dart';
import 'package:rojgar/feature/auth/domain/usecases/upload_profilepicture_usecase.dart';
import 'package:rojgar/feature/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final UploadProfilePictureUsecase _uploadProfilePictureUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _uploadProfilePictureUsecase = ref.read(uploadProfilePictureUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(seconds: 2));

    final params = RegisterUsecaseParams(
      email: email,
      username: username,
      password: password,
    );
    final result = await _registerUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _getCurrentUserUsecase();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    state = state.copyWith(status: AuthStatus.loading);
    final userId = state.authEntity?.authId;
    if (userId == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'User not logged in',
      );
      return;
    }
    final params = UploadProfilePictureUsecaseParams(
      imageFile: imageFile,
      userId: userId,
    );
    final result = await _uploadProfilePictureUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (updatedAuthEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: updatedAuthEntity,
        );
      },
    );
  }

  Future<void> logout() async {}
}