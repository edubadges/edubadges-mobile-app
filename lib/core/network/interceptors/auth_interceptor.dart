import 'package:dio/dio.dart';

/// Interceptor for adding authentication headers to requests
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getAccessToken;
  final Future<String?> Function()? getRefreshToken;
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor({
    required this.getAccessToken,
    this.getRefreshToken,
    this.onUnauthorized,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token
    final token = await getAccessToken();

    // Add authorization header if token exists
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      // Notify about unauthorized access
      await onUnauthorized?.call();
    }

    super.onError(err, handler);
  }
}
