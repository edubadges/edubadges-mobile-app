import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

/// SurfConext's token endpoint does not always use RFC 6749 `invalid_grant`
/// when the refresh token is gone. It returns this custom `error` value
/// instead (HTTP 400). Treating that as transient left users stuck retrying
/// a session that can never recover.
const String surfConextRefreshTokenNotFound = 'RefreshToken not found';

/// Whether [error] means the stored grant can never succeed again.
///
/// Only these warrant clearing the session. Network failures, timeouts and
/// server errors are transient: clearing tokens for those logs the user out
/// every time a refresh happens to run while the connection is unavailable.
bool isPermanentAuthFailure(Object error) {
  return _isPermanentOAuthErrorCode(_oauthErrorCode(error));
}

String? _oauthErrorCode(Object error) {
  if (error is FlutterAppAuthPlatformException) {
    return error.platformErrorDetails.error;
  }
  if (error is DioException) {
    final int? statusCode = error.response?.statusCode;
    if (statusCode != 400 && statusCode != 401) {
      return null;
    }
    final dynamic data = error.response?.data;
    if (data is Map) {
      final Object? code = data['error'];
      return code is String ? code : null;
    }
  }
  return null;
}

bool _isPermanentOAuthErrorCode(String? code) {
  if (code == null || code.isEmpty) {
    return false;
  }
  final String normalized = code.trim().toLowerCase();
  return normalized == FlutterAppAuthOAuthError.invalidGrant ||
      normalized == FlutterAppAuthOAuthError.invalidClient ||
      normalized == FlutterAppAuthOAuthError.unauthorizedClient ||
      normalized == FlutterAppAuthOAuthError.invalidScope ||
      normalized == surfConextRefreshTokenNotFound.toLowerCase();
}

/// Whether [error] means SurfConext could not be reached at all: no network,
/// a host name that does not resolve, or a timeout.
///
/// Those are worth telling the user about, so an unreachable login service
/// does not look like the app is broken. They never clear the session.
bool isNetworkAuthFailure(Object error) {
  if (error is FlutterAppAuthPlatformException) {
    final FlutterAppAuthPlatformErrorDetails details =
        error.platformErrorDetails;
    // AppAuth-Android: TYPE_GENERAL_ERROR / GeneralErrors.NETWORK_ERROR.
    if (details.type == '0' && details.code == '3') {
      return true;
    }
    // AppAuth-iOS: OIDErrorCodeNetworkError, or a URL loading error
    // underneath (NSURLErrorCannotFindHost for a failed DNS lookup).
    return (details.type == 'org.openid.appauth.general' &&
            details.code == '-5') ||
        details.domain == 'NSURLErrorDomain';
  }
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => true,
      _ => false,
    };
  }
  return false;
}
