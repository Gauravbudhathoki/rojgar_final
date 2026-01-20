import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rojgar/core/api/api_endpoints.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: ApiEndpoints.connectionTimeout,
            receiveTimeout: ApiEndpoints.receiveTimeout,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(AuthInterceptor(_storage));

    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, _) =>
            error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) {
    return _dio.post(path,
        data: data,
        queryParameters: queryParameters,
        options: options);
  }

  Future<Response> put(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) {
    return _dio.put(path,
        data: data,
        queryParameters: queryParameters,
        options: options);
  }

  Future<Response> delete(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) {
    return _dio.delete(path,
        data: data,
        queryParameters: queryParameters,
        options: options);
  }
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  static const _tokenKey = 'auth_token';
  String? _cachedToken;

  AuthInterceptor(this.storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final isAuth =
        options.path == ApiEndpoints.login ||
        options.path == ApiEndpoints.register;

    if (!isAuth) {
      _cachedToken ??= await storage.read(key: _tokenKey);
      if (_cachedToken != null) {
        options.headers['Authorization'] = 'Bearer $_cachedToken';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _cachedToken = null;
      storage.delete(key: _tokenKey);
    }
    handler.next(err);
  }
}
