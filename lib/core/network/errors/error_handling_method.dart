/// Defines how errors should be handled for a specific request
enum ErrorHandlingMethod {
  /// Everything will be handled by the app (AromaError is bypassed)
  excludeAll,

  /// Only these types will be handled by the app, the rest by AromaError
  excludeTypes,

  /// Everything will be handled by AromaError (default)
  handleAll,

  /// Only these types will be handled by AromaError, the rest by the app
  onlyHandleTypes,
}

/// Configuration for error handling with optional type filters
class ErrorHandlingConfig {
  final ErrorHandlingMethod method;
  final List<String>? types;

  const ErrorHandlingConfig({
    required this.method,
    this.types,
  });

  /// Default configuration - handle all errors with AromaError
  const ErrorHandlingConfig.default_()
      : method = ErrorHandlingMethod.handleAll,
        types = null;

  /// Exclude all errors from AromaError handling
  const ErrorHandlingConfig.excludeAll()
      : method = ErrorHandlingMethod.excludeAll,
        types = null;

  /// Exclude specific error types from AromaError handling
  const ErrorHandlingConfig.excludeTypes(List<String> types)
      : method = ErrorHandlingMethod.excludeTypes,
        types = types;

  /// Only handle specific error types with AromaError
  const ErrorHandlingConfig.onlyHandleTypes(List<String> types)
      : method = ErrorHandlingMethod.onlyHandleTypes,
        types = types;
}
