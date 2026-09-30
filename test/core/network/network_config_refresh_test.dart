import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:edubadges/core/auth/oidc_error_classifier.dart';
import 'package:edubadges/core/network/auth_error_constants.dart';
import 'package:edubadges/core/network/network_config.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_dio/fresh_dio.dart';

class _MemoryTokenStorage implements TokenStorage<OAuth2Token> {
  _MemoryTokenStorage(this.token);

  OAuth2Token? token;

  @override
  Future<void> delete() async => token = null;

  @override
  Future<OAuth2Token?> read() async => token;

  @override
  Future<void> write(OAuth2Token token) async => this.token = token;
}

/// Answers every request the way the API does for an expired access token.
class _InvalidCredentialsAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({'detail': AuthErrorConstants.invalidCredentialsDetail}),
      403,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

FlutterAppAuthPlatformException _appAuthException(
  FlutterAppAuthPlatformErrorDetails details,
) {
  return FlutterAppAuthPlatformException(
    code: 'token_failed',
    message: 'Failed to get token',
    platformErrorDetails: details,
  );
}

void main() {
  late _MemoryTokenStorage storage;

  Dio createDio(Future<OAuth2Token> Function() onRefreshToken) {
    final Dio dio = NetworkConfig(
      baseUrl: 'https://api.example.test',
      tokenStorage: storage,
      onRefreshToken: onRefreshToken,
      maxRetries: 0,
    ).createDio();
    dio.httpClientAdapter = _InvalidCredentialsAdapter();
    return dio;
  }

  setUp(() {
    storage = _MemoryTokenStorage(
      const OAuth2Token(
        accessToken: 'expired-access-token',
        refreshToken: 'refresh-token',
      ),
    );
  });

  test('clears the token when SurfConext rejects the refresh token', () async {
    final Dio dio = createDio(
      () async => throw _appAuthException(
        FlutterAppAuthPlatformErrorDetails(
          error: surfConextRefreshTokenNotFound,
        ),
      ),
    );

    await expectLater(
      dio.get<dynamic>('/badges'),
      throwsA(
        isA<DioException>().having(
          (e) => e.error,
          'error',
          isA<RevokeTokenException>(),
        ),
      ),
    );
    expect(storage.token, isNull);
  });

  test(
    'fails the request as a network error when SurfConext cannot be reached',
    () async {
      final Dio dio = createDio(
        () async => throw _appAuthException(
          FlutterAppAuthPlatformErrorDetails(type: '0', code: '3'),
        ),
      );

      await expectLater(
        dio.get<dynamic>('/badges'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionError,
          ),
        ),
      );
      expect(storage.token?.refreshToken, 'refresh-token');
    },
  );

  test(
    'fails the request instead of returning the 403 on any other refresh error',
    () async {
      final Dio dio = createDio(() async => throw Exception('unexpected'));

      await expectLater(
        dio.get<dynamic>('/badges'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.unknown,
          ),
        ),
      );
      expect(storage.token?.refreshToken, 'refresh-token');
    },
  );
}
