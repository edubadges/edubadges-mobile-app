/// Standard error codes used throughout the application
class ErrorCodes {
  ErrorCodes._();

  // Network errors
  static const String networkError = 'NETWORK_ERROR';
  static const String noInternetConnection = 'NO_INTERNET_CONNECTION';
  static const String requestTimeout = 'REQUEST_TIMEOUT';
  static const String requestCancelled = 'REQUEST_CANCELLED';

  // Server errors
  static const String serverError = 'SERVER_ERROR';
  static const String internalServerError = 'INTERNAL_SERVER_ERROR';
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';

  // Client errors
  static const String badRequest = 'BAD_REQUEST';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String validationError = 'VALIDATION_ERROR';
  static const String conflict = 'CONFLICT';

  // Data errors
  static const String parsingError = 'PARSING_ERROR';
  static const String cacheError = 'CACHE_ERROR';

  // Unknown errors
  static const String unknownError = 'UNKNOWN_ERROR';
}
