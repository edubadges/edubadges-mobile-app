import 'dart:convert';

import 'package:edubadges/core/auth/oidc_error_classifier.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/shared/data/datasources/oidc_auth_datasource.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _appAuthChannel = MethodChannel(
  'crossingthestreams.io/flutter_appauth',
);

/// Makes every AppAuth call fail the way the native plugin reports it.
void _failAppAuthWith(Map<String, String> details) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_appAuthChannel, (MethodCall call) async {
        throw PlatformException(
          code: '${call.method}_failed',
          message: 'AppAuth failed',
          details: details,
        );
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (!EnvironmentConfig.instance.isInitialized) {
      EnvironmentConfig.instance.init(
        apiUrl: 'https://api.example.test',
        openIdUrl: 'https://login.example.test',
        openIdClientId: 'test-client',
        enableAnalytics: false,
        enableCrashlytics: false,
        publicCollectionBaseUrl: 'https://example.test',
        piwikProBaseUrl: 'https://analytics.example.test',
        piwikProSiteId: 'test-site',
      );
    }
  });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'oauth2_token': jsonEncode({
        'accessToken': 'old-access-token',
        'refreshToken': 'old-refresh-token',
        'tokenType': 'bearer',
      }),
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_appAuthChannel, null);
  });

  group('refreshToken', () {
    test(
      'clears the session and reports it when SurfConext rejects the token',
      () async {
        _failAppAuthWith({'error': surfConextRefreshTokenNotFound});
        final dataSource = OidcAuthDataSource();
        var expired = 0;
        final subscription = dataSource.sessionExpired.listen((_) => expired++);
        addTearDown(subscription.cancel);

        await expectLater(
          dataSource.refreshToken(),
          throwsA(isA<FlutterAppAuthPlatformException>()),
        );
        await Future<void>.delayed(Duration.zero);

        expect(await dataSource.tokenStorage.read(), isNull);
        expect(expired, 1);
      },
    );

    test('keeps the session when SurfConext cannot be reached', () async {
      // AppAuth-Android GeneralErrors.NETWORK_ERROR, e.g. a failed DNS lookup.
      _failAppAuthWith({
        'type': '0',
        'code': '3',
        'error_description': 'Network error',
      });
      final dataSource = OidcAuthDataSource();
      var expired = 0;
      final subscription = dataSource.sessionExpired.listen((_) => expired++);
      addTearDown(subscription.cancel);

      await expectLater(
        dataSource.refreshToken(),
        throwsA(isA<FlutterAppAuthPlatformException>()),
      );
      await Future<void>.delayed(Duration.zero);

      final stored = await dataSource.tokenStorage.read();
      expect(stored?.refreshToken, 'old-refresh-token');
      expect(expired, 0);
    });
  });

  group('login', () {
    test('reports an unreachable SurfConext as a NetworkException', () async {
      // AppAuth-iOS OIDErrorCodeNetworkError on top of a failed host lookup.
      _failAppAuthWith({
        'type': 'org.openid.appauth.general',
        'code': '-5',
        'domain': 'NSURLErrorDomain',
      });

      await expectLater(
        OidcAuthDataSource().login(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('passes a cancelled login through unchanged', () async {
      _failAppAuthWith({
        'type': 'org.openid.appauth.general',
        'code': '-3',
        'user_did_cancel': 'true',
      });

      await expectLater(
        OidcAuthDataSource().login(),
        throwsA(isA<FlutterAppAuthUserCancelledException>()),
      );
    });
  });
}
