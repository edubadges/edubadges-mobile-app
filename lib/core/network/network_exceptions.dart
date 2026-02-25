import 'dart:convert';
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
    dynamic data = response?.data;

    int? apiErrorCodeFromWrapper;
    if (error.error is HandledError) {
      final original = (error.error as HandledError).originalError;
      if (original is ValidationException && original.apiErrorCode != null) {
        apiErrorCodeFromWrapper = original.apiErrorCode;
      }
    }

    // Normalize body: parse if String, ensure we have a Map for extraction
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        // Leave data as String, will use as message below
      }
    }
    // Some platforms return Map with non-String keys; normalize for safe access
    final dataMap = _toMap(data);

    String message = 'An error occurred';
    String? code;
    Map<String, List<String>>? validationErrors;
    int? apiErrorCode = apiErrorCodeFromWrapper;

    if (dataMap != null) {
      message =
          dataMap['message'] as String? ??
          dataMap['error'] as String? ??
          dataMap['detail'] as String? ??
          message;

      // For 400/422 extract API error_code: try exact path first, then recursive
      if (apiErrorCode == null && (statusCode == 400 || statusCode == 422)) {
        apiErrorCode = _extractApiErrorCodeFromBody(dataMap);
      }
      if (apiErrorCode != null) {
        code = apiErrorCode.toString();
      }

      if (dataMap['errors'] != null) {
        validationErrors = _extractValidationErrors(dataMap['errors']);
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
          apiErrorCode: apiErrorCode,
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
          apiErrorCode: apiErrorCode,
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

  static Map<String, dynamic>? _toMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      try {
        return Map<String, dynamic>.from(data);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static int? _extractApiErrorCodeFromBody(Map<String, dynamic> dataMap) {
    // Exact path: fields -> error_message -> name -> [0] -> error_code
    try {
      final fields = dataMap['fields'] ?? dataMap['field'];
      if (fields is Map) {
        final fm = Map<String, dynamic>.from(fields);
        final errorMessage = fm['error_message'];
        if (errorMessage is Map) {
          final em = Map<String, dynamic>.from(errorMessage);
          final nameList = em['name'];
          if (nameList is List && nameList.isNotEmpty) {
            final first = nameList.first;
            if (first is Map) {
              final firstMap = Map<String, dynamic>.from(first);
              final code = firstMap['error_code'];
              if (code is String) {
                if (int.tryParse(code) != 999) {
                  return int.tryParse(code);
                }
              }
              if (code is int && code != 999) return code;
              if (code is num) {
                final n = code.toInt();
                if (n != 999) return n;
              }
            }
          }
        }
      }
    } catch (_) {
      // Fall through to recursive extraction
    }
    final fieldsRaw = dataMap['fields'] ?? dataMap['field'];
    int? code = _extractApiErrorCode(fieldsRaw);
    code ??= _extractApiErrorCode(dataMap);
    code ??= _extractAnyApiErrorCode(fieldsRaw) ?? _extractAnyApiErrorCode(dataMap);
    return code;
  }

  static int? _extractApiErrorCode(dynamic fields) {
    if (fields == null) return null;
    if (fields is int) return fields == 999 ? null : fields;
    if (fields is num) {
      final n = fields.toInt();
      return n == 999 ? null : n;
    }
    if (fields is Map) {
      for (final value in fields.values) {
        final found = _extractApiErrorCode(value);
        if (found != null) return found;
      }
      final codeValue = fields['error_code'];
      if (codeValue is int) return codeValue == 999 ? null : codeValue;
      if (codeValue is num) {
        final n = codeValue.toInt();
        return n == 999 ? null : n;
      }
    }
    if (fields is List) {
      for (final item in fields) {
        final found = _extractApiErrorCode(item);
        if (found != null) return found;
      }
    }
    return null;
  }

  static int? _extractAnyApiErrorCode(dynamic fields) {
    if (fields == null) return null;
    if (fields is int) return fields;
    if (fields is num) return fields.toInt();
    if (fields is Map) {
      for (final value in fields.values) {
        final found = _extractAnyApiErrorCode(value);
        if (found != null) return found;
      }
      final codeValue = fields['error_code'];
      if (codeValue is int) return codeValue;
      if (codeValue is num) return codeValue.toInt();
    }
    if (fields is List) {
      for (final item in fields) {
        final found = _extractAnyApiErrorCode(item);
        if (found != null) return found;
      }
    }
    return null;
  }
}
