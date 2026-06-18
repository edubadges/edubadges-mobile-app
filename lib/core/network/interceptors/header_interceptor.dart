
import 'package:dio/dio.dart';

/// Interceptor for adding common headers to all requests
class HeaderInterceptor extends Interceptor {
  final String? userAgent;
  final String? acceptLanguage;
  final Map<String, String>? customHeaders;

  HeaderInterceptor({this.userAgent, this.acceptLanguage, this.customHeaders});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add common headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    // Add user agent if provided
    if (userAgent != null) {
      options.headers['User-Agent'] = userAgent;
    }

    // Add accept language if provided
    if (acceptLanguage != null) {
      options.headers['Accept-Language'] = acceptLanguage;
    }

    // Add custom headers if provided
    customHeaders?.forEach((key, value) {
      options.headers[key] = value;
    });

    super.onRequest(options, handler);
  }
}
