import 'dart:io';

import 'package:dio/dio.dart';

/// Interceptor for retrying failed requests
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryableStatusCodes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if request should be retried
    if (_shouldRetry(err)) {
      final retries = err.requestOptions.extra['retries'] as int? ?? 0;

      if (retries < maxRetries) {
        // Increment retry count
        err.requestOptions.extra['retries'] = retries + 1;

        // Wait before retrying
        await Future.delayed(retryDelay * (retries + 1), () => null);

        try {
          // Retry the request
          final response = await Dio().fetch<Response<void>>(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.reject(e);
        }
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // Don't retry on cancel
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // Retry on socket exceptions
    if (err.error is SocketException) {
      return true;
    }

    // Retry on specific status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }
}
