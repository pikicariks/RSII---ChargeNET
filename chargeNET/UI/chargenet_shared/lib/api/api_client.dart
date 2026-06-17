import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': 'application/pdf'},
        ),
      ),
      parser: (json) {
        if (json is Uint8List) return json;
        if (json is List<int>) return Uint8List.fromList(json);
        return Uint8List(0);
      },
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

  Future<T> patch<T>(
    String path, {
    Object? data,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () => _dio.patch<dynamic>(path, data: data),
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
    } else if (data is Uint8List && data.isNotEmpty) {
      try {
        final text = String.fromCharCodes(data).trim();
        if (text.startsWith('{')) {
          final decoded = jsonDecode(text) as Map<String, dynamic>;
          final raw = decoded['message'];
          if (raw is String && raw.isNotEmpty) {
            message = raw;
          }
        } else if (text.isNotEmpty) {
          message = text;
        }
      } catch (_) {
        // Keep default message for non-JSON error bodies.
      }
    } else if (data is List<int> && data.isNotEmpty) {
      try {
        final text = String.fromCharCodes(data).trim();
        if (text.startsWith('{')) {
          final decoded = jsonDecode(text) as Map<String, dynamic>;
          final raw = decoded['message'];
          if (raw is String && raw.isNotEmpty) {
            message = raw;
          }
        } else if (text.isNotEmpty) {
          message = text;
        }
      } catch (_) {
        // Keep default message for non-JSON error bodies.
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Is the backend running?';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Cannot reach the server at ${_dio.options.baseUrl}.';
    }

    if (statusCode == 404) {
      message = 'Resource not found (404).';
    } else if (statusCode == 401) {
      message = 'Unauthorized. Please sign in again.';
    } else if (statusCode == 403) {
      message = 'Forbidden. Admin access required.';
    }

    return ApiException(message: message, statusCode: statusCode);
  }
}
