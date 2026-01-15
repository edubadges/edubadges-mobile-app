import 'package:dio/dio.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/core/network/network_exceptions.dart';

/// Interceptor for handling errors with AromaErrorController
class ErrorInterceptor extends Interceptor {

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Convert DioException to AppException
    final appException = NetworkExceptionHandler.handleError(err, err.stackTrace);

    // Check if this is an HTTP error with a response body
    final response = err.response;
    final responseData = response?.data;

    if (responseData is Map<String, dynamic> && responseData.containsKey('type')) {
      // Extract error information from response body
      // final errorType = responseData['type'] as String? ?? 'UnknownError';
      final errorMessage = responseData['message'] as String? ?? appException.message;
      final errorCode = responseData['code'] as int? ?? response?.statusCode ?? 0;

      // Wrap the original error in HandledError
      final handledError = HandledError(
        message: errorMessage,
        isHandled: true,
        code: errorCode.toString(),
        originalError: appException,
        stackTrace: err.stackTrace,
      );

      // Create a new DioException with the wrapped error
      final wrappedDioException = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: handledError,
        stackTrace: err.stackTrace,
      );

      super.onError(wrappedDioException, handler);
    } else {
      // Wrap the original error in HandledError
      final handledError = HandledError(
        message: appException.message,
        isHandled: true,
        code: appException.code,
        originalError: appException,
        stackTrace: err.stackTrace,
      );

      // Create a new DioException with the wrapped error
      final wrappedDioException = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: handledError,
        stackTrace: err.stackTrace,
      );

      super.onError(wrappedDioException, handler);
    }
  }
}