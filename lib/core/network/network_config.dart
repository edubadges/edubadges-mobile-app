import 'package:dio/dio.dart';
import 'package:edubadges/core/network/interceptors/header_interceptor.dart';
import 'package:edubadges/core/network/interceptors/logging_interceptor.dart';
import 'package:edubadges/core/network/interceptors/retry_interceptor.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:logger/logger.dart';

/// Configuration for creating a Dio instance with interceptors
class NetworkConfig {
  /// Base URL for API requests
  final String baseUrl;

  /// Token storage for OAuth2 tokens
  final TokenStorage<OAuth2Token>? tokenStorage;

  /// Callback to refresh the token when it expires
  final Future<OAuth2Token> Function()? onRefreshToken;

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

  NetworkConfig({
    required this.baseUrl,
    this.tokenStorage,
    this.onRefreshToken,
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

  Fresh<OAuth2Token>? _fresh;

  /// Get the Fresh instance for manual token updates
  Fresh<OAuth2Token>? get fresh => _fresh;

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
      RetryInterceptor(maxRetries: maxRetries, retryDelay: retryDelay),
    );

    // Auth interceptor (only if tokenStorage is provided)
    if (tokenStorage != null && onRefreshToken != null) {
      _fresh = Fresh.oAuth2(
        tokenStorage: tokenStorage!,
        tokenHeader: (token) {
          return {'Authorization': 'Bearer ${token.accessToken}'};
        },
        shouldRefresh: (response) {
          // TODO: 403 is temp till demo server is updated to just use 401
          const authErrorCodes = {401, 403};
          return response != null &&
              authErrorCodes.contains(response.statusCode);
        },
        refreshToken: (token, client) async {
          try {
            return await onRefreshToken!();
          } catch (e) {
            throw RevokeTokenException();
          }
        },
      );
      interceptors.add(_fresh!);
    }

    dio.interceptors.addAll(interceptors);
    return dio;
  }
}
