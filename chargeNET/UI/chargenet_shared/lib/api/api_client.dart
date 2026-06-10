import 'package:dio/dio.dart';

import '../auth/token_storage.dart';
import 'api_exception.dart';

typedef OnUnauthorized = void Function();

/// Dio HTTP client with JWT attach, 401 handling, and error mapping.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    OnUnauthorized? onUnauthorized,
    Dio? dio,
  })  : _tokenStorage = tokenStorage,
        _onUnauthorized = onUnauthorized,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.clear();
            _onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final OnUnauthorized? _onUnauthorized;

  Dio get dio => _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
      parser: parser,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () => _dio.post<dynamic>(path, data: data),
      parser: parser,
    );
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () => _dio.put<dynamic>(path, data: data),
      parser: parser,
    );
  }

  Future<void> delete(String path) async {
    await _request<void>(() => _dio.delete<dynamic>(path));
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() call, {
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await call();
      final body = response.data;
      if (parser != null) {
        return parser(body);
      }
      return body as T;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ApiException _mapDioError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    var message = 'Network request failed.';

    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final raw = data['message'];
      if (raw is String && raw.isNotEmpty) {
        message = raw;
      }
      final rawErrors = data['errors'];
      if (rawErrors is List) {
        return ApiException(
          message: message,
          statusCode: statusCode,
          errors: rawErrors.whereType<String>().toList(),
        );
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Is the backend running?';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Cannot reach the server at ${_dio.options.baseUrl}.';
    }

    return ApiException(message: message, statusCode: statusCode);
  }
}
