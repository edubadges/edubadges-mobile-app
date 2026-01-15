/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Exception thrown when Error handles the error
class HandledError extends AppException {
  final bool isHandled;

  const HandledError({
    required super.message,
    required this.isHandled,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'HandledError(message: $message, isHandled: $isHandled, code: $code)';
}

/// Exception thrown when there's a server error (5xx)
class ServerException extends AppException {
  final int statusCode;

  const ServerException({
    required super.message,
    required this.statusCode,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode, code: $code)';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NetworkException(message: $message, code: $code)';
}

/// Exception thrown when the request is unauthorized (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'UnauthorizedException(message: $message, code: $code)';
}

/// Exception thrown when access is forbidden (403)
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Access forbidden',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ForbiddenException(message: $message, code: $code)';
}

/// Exception thrown when the resource is not found (404)
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NotFoundException(message: $message, code: $code)';
}

/// Exception thrown when there's a validation error (400, 422)
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required super.message,
    this.errors,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'ValidationException(message: $message, errors: $errors, code: $code)';
}

/// Exception thrown when there's a timeout
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timeout',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'TimeoutException(message: $message, code: $code)';
}

/// Exception thrown when there's a cache-related error
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'CacheException(message: $message, code: $code)';
}

/// Exception thrown when there's a parsing error
class ParsingException extends AppException {
  const ParsingException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ParsingException(message: $message, code: $code)';
}

/// Exception thrown when there's an unexpected error
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'UnknownException(message: $message, code: $code)';
}

/// Exception thrown when Firebase Auth operation fails
class FirebaseAuthException extends AppException {
  const FirebaseAuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'FirebaseAuthException(message: $message, code: $code)';
}

/// Exception thrown when verification code is invalid or expired
class InvalidVerificationCodeException extends AppException {
  const InvalidVerificationCodeException({
    super.message = 'Invalid or expired verification code',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'InvalidVerificationCodeException(message: $message, code: $code)';
}

/// Exception thrown when too many verification code requests
class TooManyRequestsException extends AppException {
  const TooManyRequestsException({
    super.message = 'Too many requests. Please try again later',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'TooManyRequestsException(message: $message, code: $code)';
}
