import 'package:dio/dio.dart';
import 'package:edubadges/core/auth/oidc_error_classifier.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';

FlutterAppAuthPlatformException _appAuthException({required String? error}) {
  return FlutterAppAuthPlatformException(
    code: 'token_failed',
    message: 'Failed to get token',
    platformErrorDetails: FlutterAppAuthPlatformErrorDetails(error: error),
  );
}

FlutterAppAuthPlatformException _appAuthGeneralException({
  String? type,
  String? code,
  String? domain,
}) {
  return FlutterAppAuthPlatformException(
    code: 'authorize_and_exchange_code_failed',
    message: 'Failed to authorize',
    platformErrorDetails: FlutterAppAuthPlatformErrorDetails(
      type: type,
      code: code,
      domain: domain,
    ),
  );
}

DioException _tokenEndpointException({
  required int statusCode,
  required Object? data,
}) {
  final RequestOptions requestOptions = RequestOptions(path: '/oidc/token');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}

void main() {
  group('isPermanentAuthFailure', () {
    test(
      'treats SurfConext RefreshToken not found from AppAuth as permanent',
      () {
        expect(
          isPermanentAuthFailure(
            _appAuthException(error: surfConextRefreshTokenNotFound),
          ),
          isTrue,
        );
      },
    );

    test(
      'treats SurfConext RefreshToken not found from the token endpoint as permanent',
      () {
        expect(
          isPermanentAuthFailure(
            _tokenEndpointException(
              statusCode: 400,
              data: <String, dynamic>{
                'error': surfConextRefreshTokenNotFound,
                'error_description': surfConextRefreshTokenNotFound,
                'message': surfConextRefreshTokenNotFound,
                'path': '/oidc/token',
                'status': 400,
              },
            ),
          ),
          isTrue,
        );
      },
    );

    test('matches the custom SurfConext error regardless of case', () {
      expect(
        isPermanentAuthFailure(
          _appAuthException(error: 'refreshtoken not found'),
        ),
        isTrue,
      );
    });

    test('treats standard OAuth grant rejections as permanent', () {
      expect(
        isPermanentAuthFailure(
          _appAuthException(error: FlutterAppAuthOAuthError.invalidGrant),
        ),
        isTrue,
      );
      expect(
        isPermanentAuthFailure(
          _tokenEndpointException(
            statusCode: 400,
            data: <String, dynamic>{'error': 'invalid_client'},
          ),
        ),
        isTrue,
      );
      expect(
        isPermanentAuthFailure(
          _appAuthException(error: FlutterAppAuthOAuthError.unauthorizedClient),
        ),
        isTrue,
      );
      expect(
        isPermanentAuthFailure(
          _tokenEndpointException(
            statusCode: 401,
            data: <String, dynamic>{'error': 'invalid_scope'},
          ),
        ),
        isTrue,
      );
    });

    test('keeps the session on network and server failures', () {
      expect(isPermanentAuthFailure(Exception('socket hang up')), isFalse);
      expect(isPermanentAuthFailure(_appAuthException(error: null)), isFalse);
      expect(
        isPermanentAuthFailure(_appAuthException(error: 'discovery_failed')),
        isFalse,
      );
      expect(
        isPermanentAuthFailure(
          DioException(
            requestOptions: RequestOptions(path: '/oidc/token'),
            type: DioExceptionType.connectionError,
          ),
        ),
        isFalse,
      );
      expect(
        isPermanentAuthFailure(
          _tokenEndpointException(
            statusCode: 500,
            data: <String, dynamic>{'error': surfConextRefreshTokenNotFound},
          ),
        ),
        isFalse,
      );
      expect(
        isPermanentAuthFailure(
          _tokenEndpointException(
            statusCode: 400,
            data: 'RefreshToken not found',
          ),
        ),
        isFalse,
      );
    });
  });
  group('isNetworkAuthFailure', () {
    test('recognises an AppAuth-Android network error', () {
      expect(
        isNetworkAuthFailure(_appAuthGeneralException(type: '0', code: '3')),
        isTrue,
      );
    });

    test('recognises an AppAuth-iOS network error', () {
      expect(
        isNetworkAuthFailure(
          _appAuthGeneralException(
            type: 'org.openid.appauth.general',
            code: '-5',
          ),
        ),
        isTrue,
      );
    });

    test('recognises a failed host lookup underneath an iOS error', () {
      expect(
        isNetworkAuthFailure(
          _appAuthGeneralException(
            type: 'org.openid.appauth.general',
            code: '-6',
            domain: 'NSURLErrorDomain',
          ),
        ),
        isTrue,
      );
    });

    test(
      'recognises connection errors and timeouts from the token endpoint',
      () {
        for (final DioExceptionType type in [
          DioExceptionType.connectionError,
          DioExceptionType.connectionTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.receiveTimeout,
        ]) {
          expect(
            isNetworkAuthFailure(
              DioException(
                requestOptions: RequestOptions(path: '/oidc/token'),
                type: type,
              ),
            ),
            isTrue,
            reason: '$type',
          );
        }
      },
    );

    test('does not treat rejections or other failures as network errors', () {
      expect(
        isNetworkAuthFailure(
          _appAuthException(error: surfConextRefreshTokenNotFound),
        ),
        isFalse,
      );
      expect(
        isNetworkAuthFailure(
          _appAuthGeneralException(
            type: 'org.openid.appauth.general',
            code: '-3',
          ),
        ),
        isFalse,
      );
      expect(
        isNetworkAuthFailure(
          _tokenEndpointException(
            statusCode: 500,
            data: <String, dynamic>{'error': 'server_error'},
          ),
        ),
        isFalse,
      );
      expect(isNetworkAuthFailure(Exception('boom')), isFalse);
    });
  });
}
