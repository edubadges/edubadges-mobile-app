import 'dart:io';

import 'package:dio/dio.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';

/// Utility class to convert Dio exceptions to custom exceptions
class NetworkExceptionHandler {
  NetworkExceptionHandler._();

  /// Converts Dio exceptions and other errors to custom exceptions
  static AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      return _handleDioException(error, stackTrace);
    }

    if (error is SocketException) {
      return NetworkException(
        message: 'No internet connection',
        code: ErrorCodes.noInternetConnection,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message: error.toString(),
      code: ErrorCodes.unknownError,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppException _handleDioException(
    DioException error,
    StackTrace? stackTrace,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timeout. Please try again.',
          code: ErrorCodes.requestTimeout,
          originalError: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error, stackTrace);

      case DioExceptionType.cancel:
        return UnknownException(
          message: 'Request cancelled',
          code: ErrorCodes.requestCancelled,
          originalError: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(
            message: 'No internet connection',
            code: ErrorCodes.noInternetConnection,
            originalError: error,
            stackTrace: stackTrace,
          );
        }
        return NetworkException(
          message: 'Network error occurred',
          code: ErrorCodes.networkError,
          originalError: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Bad certificate',
          code: ErrorCodes.networkError,
          originalError: error,
          stackTrace: stackTrace,
        );
    }
  }

  static AppException _handleBadResponse(
    DioException error,
    StackTrace? stackTrace,
  ) {
    final response = error.response;
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;

    // Extract error message from response
    String message = 'An error occurred';
    String? code;
    Map<String, List<String>>? validationErrors;

    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String? ??
          message;

      // Handle code as either String or int
      final codeValue = data['code'];
      if (codeValue is String) {
        code = codeValue;
      } else if (codeValue is int) {
        code = codeValue.toString();
      }

      // Extract validation errors if present
      if (data['errors'] != null) {
        validationErrors = _extractValidationErrors(data['errors']);
      }
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          errors: validationErrors,
          code: code ?? ErrorCodes.badRequest,
          originalError: error,
          stackTrace: stackTrace,
        );

      case 401:
        return UnauthorizedException(
          message: message,
          code: code ?? ErrorCodes.unauthorized,
          originalError: error,
          stackTrace: stackTrace,
        );

      case 403:
        return ForbiddenException(
          message: message,
          code: code ?? ErrorCodes.forbidden,
          originalError: error,
          stackTrace: stackTrace,
        );

      case 404:
        return NotFoundException(
          message: message,
          code: code ?? ErrorCodes.notFound,
          originalError: error,
          stackTrace: stackTrace,
        );

      case 422:
        return ValidationException(
          message: message,
          errors: validationErrors,
          code: code ?? ErrorCodes.validationError,
          originalError: error,
          stackTrace: stackTrace,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message,
          statusCode: statusCode,
          code: code ?? ErrorCodes.serverError,
          originalError: error,
          stackTrace: stackTrace,
        );

      default:
        if (statusCode >= 500) {
          return ServerException(
            message: message,
            statusCode: statusCode,
            code: code ?? ErrorCodes.serverError,
            originalError: error,
            stackTrace: stackTrace,
          );
        }
        return UnknownException(
          message: message,
          code: code ?? ErrorCodes.unknownError,
          originalError: error,
          stackTrace: stackTrace,
        );
    }
  }

  static Map<String, List<String>>? _extractValidationErrors(dynamic errors) {
    if (errors is Map<String, dynamic>) {
      final result = <String, List<String>>{};
      errors.forEach((key, value) {
        if (value is List) {
          result[key] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          result[key] = [value];
        }
      });
      return result.isEmpty ? null : result;
    }
    return null;
  }
}
