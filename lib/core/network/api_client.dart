
import 'package:dio/dio.dart';
import 'package:edubadges/core/network/errors/error_handling_method.dart';
import 'package:edubadges/core/network/network_exceptions.dart';

class ApiClient {
  final Dio _dio;
  bool _isInitialized = false;

  ApiClient({required String baseUrl, required Dio dio}) : _dio = dio {
    _dio.options.baseUrl = baseUrl;
  }

  Dio get dio => _dio;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ErrorHandlingConfig? errorHandlingMethod,
  }) async {
    try {
      final requestOptions = options ?? Options();
      requestOptions.extra ??= {};
      if (errorHandlingMethod != null) {
        requestOptions.extra!['errorHandlingMethod'] = errorHandlingMethod;
      }
      
      // Merge default query parameters with provided ones
      final mergedQueryParameters = <String, dynamic>{
        'format': 'json',
        ...?queryParameters,
      };
      
      return await _dio.get<T>(
        path,
        queryParameters: mergedQueryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e, stackTrace) {
      throw NetworkExceptionHandler.handleError(e, stackTrace);
    }
  }

  /// POST request
  ///
  /// Throws [AppException] on error
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ErrorHandlingConfig? errorHandlingMethod,
  }) async {
    try {
      final requestOptions = options ?? Options();
      requestOptions.extra ??= {};
      if (errorHandlingMethod != null) {
        requestOptions.extra!['errorHandlingMethod'] = errorHandlingMethod;
      }
      
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e, stackTrace) {
      throw NetworkExceptionHandler.handleError(e, stackTrace);
    }
  }

  /// PUT request
  ///
  /// Throws [AppException] on error
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ErrorHandlingConfig? errorHandlingMethod,
  }) async {
    try {
      final requestOptions = options ?? Options();
      requestOptions.extra ??= {};
      if (errorHandlingMethod != null) {
        requestOptions.extra!['errorHandlingMethod'] = errorHandlingMethod;
      }
      
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e, stackTrace) {
      throw NetworkExceptionHandler.handleError(e, stackTrace);
    }
  }

  /// PATCH request
  ///
  /// Throws [AppException] on error
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ErrorHandlingConfig? errorHandlingMethod,
  }) async {
    try {
      final requestOptions = options ?? Options();
      requestOptions.extra ??= {};
      if (errorHandlingMethod != null) {
        requestOptions.extra!['errorHandlingMethod'] = errorHandlingMethod;
      }
      
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e, stackTrace) {
      throw NetworkExceptionHandler.handleError(e, stackTrace);
    }
  }

  /// DELETE request
  ///
  /// Throws [AppException] on error
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ErrorHandlingConfig? errorHandlingMethod,
  }) async {
    try {
      final requestOptions = options ?? Options();
      requestOptions.extra ??= {};
      if (errorHandlingMethod != null) {
        requestOptions.extra!['errorHandlingMethod'] = errorHandlingMethod;
      }
      
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );
    } catch (e, stackTrace) {
      throw NetworkExceptionHandler.handleError(e, stackTrace);
    }
  }

  /// Download file
  ///
  /// Throws [AppException] on error
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
    ErrorHandlingConfig? errorHandlingMethod,
  }) async {
    try {
      final requestOptions = options ?? Options();
      requestOptions.extra ??= {};
      if (errorHandlingMethod != null) {
        requestOptions.extra!['errorHandlingMethod'] = errorHandlingMethod;
      }
      
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: requestOptions,
      );
    } catch (e, stackTrace) {
      throw NetworkExceptionHandler.handleError(e, stackTrace);
    }
  }
}
