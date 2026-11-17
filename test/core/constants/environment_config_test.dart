import 'package:edubadges/core/constants/environment_config.dart';
import 'package:flutter_test/flutter_test.dart';

EnvironmentConfig _config({String? webClientId}) {
  final config = EnvironmentConfig.detached();
  if (webClientId == null) {
    config.init(
      apiUrl: 'https://api.example.test',
      openIdUrl: 'https://connect.example.test/oidc',
      openIdClientId: 'edubadges.mobile.test',
      enableAnalytics: false,
      enableCrashlytics: false,
      publicCollectionBaseUrl: 'https://example.test/public/collections',
      piwikProBaseUrl: 'https://analytics.example.test',
      piwikProSiteId: 'site',
    );
  } else {
    config.init(
      apiUrl: 'https://api.example.test',
      openIdUrl: 'https://connect.example.test/oidc',
      openIdClientId: 'edubadges.mobile.test',
      openIdWebClientId: webClientId,
      enableAnalytics: false,
      enableCrashlytics: false,
      publicCollectionBaseUrl: 'https://example.test/public/collections',
      piwikProBaseUrl: 'https://analytics.example.test',
      piwikProSiteId: 'site',
    );
  }
  return config;
}

void main() {
  group('webOpenIdClientId', () {
    test('uses the web client when one is configured', () {
      final config = _config(webClientId: 'edubadges.web.test');

      expect(config.webOpenIdClientId, 'edubadges.web.test');
      expect(config.openIdClientId, 'edubadges.mobile.test');
    });

    test('falls back to the mobile client when none is configured', () {
      expect(_config().webOpenIdClientId, 'edubadges.mobile.test');
    });

    test('falls back to the mobile client when the setting is left empty', () {
      expect(
        _config(webClientId: '').webOpenIdClientId,
        'edubadges.mobile.test',
      );
      expect(
        _config(webClientId: '   ').webOpenIdClientId,
        'edubadges.mobile.test',
      );
    });
  });
}
