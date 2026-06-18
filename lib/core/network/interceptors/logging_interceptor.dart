
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor for logging HTTP requests and responses
class LoggingInterceptor extends Interceptor {
  final Logger _logger;
  final bool logRequestBody;
  final bool logResponseBody;

  LoggingInterceptor({
    required Logger logger,
    this.logRequestBody = true,
    this.logResponseBody = true,
  }) : _logger = logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '┌──────────────────────────────────────────────────────────────────────\n'
      '│ REQUEST\n'
      '├──────────────────────────────────────────────────────────────────────\n'
      '│ ${options.method} ${options.uri}\n'
      '│ Headers: ${options.headers}\n'
      '${logRequestBody && options.data != null ? '│ Body: ${options.data}\n' : ''}'
      '└──────────────────────────────────────────────────────────────────────',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.i(
      '┌──────────────────────────────────────────────────────────────────────\n'
      '│ RESPONSE\n'
      '├──────────────────────────────────────────────────────────────────────\n'
      '│ ${response.requestOptions.method} ${response.requestOptions.uri}\n'
      '│ Status: ${response.statusCode} ${response.statusMessage}\n'
      '│ Headers: ${response.headers}\n'
      '${logResponseBody && response.data != null ? '│ Body: ${response.data}\n' : ''}'
      '└──────────────────────────────────────────────────────────────────────',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '┌──────────────────────────────────────────────────────────────────────\n'
      '│ ERROR\n'
      '├──────────────────────────────────────────────────────────────────────\n'
      '│ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '│ Type: ${err.type}\n'
      '│ Message: ${err.message}\n'
      '│ Response: ${err.response?.statusCode} ${err.response?.statusMessage}\n'
      '${err.response?.data != null ? '│ Body: ${err.response?.data}\n' : ''}'
      '└──────────────────────────────────────────────────────────────────────',
    );
    super.onError(err, handler);
  }
}
