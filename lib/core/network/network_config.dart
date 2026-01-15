import 'package:dio/dio.dart';
import 'package:edubadges/core/network/interceptors/auth_interceptor.dart';
import 'package:edubadges/core/network/interceptors/header_interceptor.dart';
import 'package:edubadges/core/network/interceptors/logging_interceptor.dart';
import 'package:edubadges/core/network/interceptors/retry_interceptor.dart';
import 'package:logger/logger.dart';

/// Configuration for creating a Dio instance with interceptors
class NetworkConfig {
  /// Base URL for API requests
  final String baseUrl;

  /// Optional access token getter for authentication
  final Future<String?> Function()? getAccessToken;

  /// Optional refresh token getter
  final Future<String?> Function()? getRefreshToken;

  /// Optional callback when unauthorized (401) is received
  final Future<void> Function()? onUnauthorized;

  /// Optional logger instance (if not provided, logging interceptor is skipped)
  final Logger? logger;

  /// Whether to log request body
  final bool logRequestBody;

  /// Whether to log response body
  final bool logResponseBody;

  /// Connect timeout duration
  final Duration connectTimeout;

  /// Receive timeout duration
  final Duration receiveTimeout;

  /// Send timeout duration
  final Duration sendTimeout;

  /// Max retries for failed requests
  final int maxRetries;

  /// Delay between retries
  final Duration retryDelay;

  /// Custom headers to add to all requests
  final Map<String, String>? customHeaders;

  /// User agent string
  final String? userAgent;

  /// Accept language header
  final String? acceptLanguage;

  const NetworkConfig({
    required this.baseUrl,
    this.getAccessToken,
    this.getRefreshToken,
    this.onUnauthorized,
    this.logger,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.customHeaders,
    this.userAgent,
    this.acceptLanguage,
  });

  /// Creates a configured Dio instance based on this config
  Dio createDio() {
    final dio = Dio();

    // Configure timeouts
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    dio.options.sendTimeout = sendTimeout;

    // Build interceptors list
    final interceptors = <Interceptor>[];

    // Header interceptor
    interceptors.add(
      HeaderInterceptor(
        userAgent: userAgent,
        acceptLanguage: acceptLanguage,
        customHeaders: customHeaders,
      ),
    );

    // Logging interceptor (only if logger is provided)
    if (logger != null) {
      interceptors.add(
        LoggingInterceptor(
          logger: logger!,
          logRequestBody: logRequestBody,
          logResponseBody: logResponseBody,
        ),
      );
    }

    // Retry interceptor
    interceptors.add(
      RetryInterceptor(
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      ),
    );

    // Auth interceptor (only if getAccessToken is provided)
    if (getAccessToken != null) {
      interceptors.add(
        AuthInterceptor(
          getAccessToken: getAccessToken!,
          getRefreshToken: getRefreshToken,
          onUnauthorized: onUnauthorized,
        ),
      );
    }

    dio.interceptors.addAll(interceptors);
    return dio;
  }
}