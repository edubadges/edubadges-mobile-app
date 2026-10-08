import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// SURF-675: a shared https://www.edubadges.nl/public/<id> link opened the
// website instead of the app. These tests read the real platform config and
// apply Android's intent-filter matching rules, so they fail if the config
// stops claiming the links the website shares.

const String _entityId = 'Kq_WelCoQ62SRMgucb_q4g';
const List<String> _hosts = [
  'www.edubadges.nl',
  'edubadges.nl',
  'demo.edubadges.nl',
];

class _AppLinkFilter {
  _AppLinkFilter(String manifest) {
    final block = RegExp(
      r'<intent-filter android:autoVerify="true">(.*?)</intent-filter>',
      dotAll: true,
    ).firstMatch(manifest)!.group(1)!;
    for (final data in RegExp(r'<data\s+([^>]*?)/>').allMatches(block)) {
      final attrs = {
        for (final a in RegExp(
          r'android:(\w+)="([^"]*)"',
        ).allMatches(data.group(1)!))
          a.group(1)!: a.group(2)!,
      };
      attrs.forEach((name, value) {
        switch (name) {
          case 'scheme':
            schemes.add(value);
          case 'host':
            hosts.add(value);
          default:
            paths.add((name, value));
        }
      });
    }
  }

  final schemes = <String>{};
  final hosts = <String>{};
  final paths = <(String, String)>[];

  /// Android's matching: `.` is any character and `*` repeats the previous
  /// one, which is exactly how the same characters read in a RegExp.
  bool _pathMatches((String, String) spec, String path) => switch (spec.$1) {
    'path' => path == spec.$2,
    'pathPrefix' => path.startsWith(spec.$2),
    'pathPattern' => RegExp('^${spec.$2}\$').hasMatch(path),
    _ => throw StateError('Unsupported path attribute ${spec.$1}'),
  };

  bool claims(String url) {
    final uri = Uri.parse(url);
    return schemes.contains(uri.scheme) &&
        hosts.contains(uri.host) &&
        (paths.isEmpty || paths.any((spec) => _pathMatches(spec, uri.path)));
  }
}

void main() {
  group('Android app links', () {
    final filter = _AppLinkFilter(
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
    );

    test('claim /public/<id> on every edubadges host', () {
      for (final host in _hosts) {
        expect(
          filter.claims('https://$host/public/$_entityId'),
          isTrue,
          reason: host,
        );
      }
    });

    test('keep claiming the older /public/catalog/<id> links', () {
      for (final host in _hosts) {
        expect(
          filter.claims('https://$host/public/catalog/$_entityId'),
          isTrue,
          reason: host,
        );
      }
    });

    test('leave collection links and other pages in the browser', () {
      for (final host in _hosts) {
        expect(
          filter.claims('https://$host/public/collections/$_entityId'),
          isFalse,
          reason: host,
        );
        expect(filter.claims('https://$host/login'), isFalse, reason: host);
        expect(filter.claims('https://$host/'), isFalse, reason: host);
      }
    });

    test('ignore other hosts and plain http', () {
      expect(filter.claims('https://example.com/public/$_entityId'), isFalse);
      expect(
        filter.claims('http://www.edubadges.nl/public/$_entityId'),
        isFalse,
      );
    });
  });

  group('iOS universal links', () {
    test('entitlements list every host', () {
      final entitlements = File(
        'ios/Runner/Runner.entitlements',
      ).readAsStringSync();
      for (final host in _hosts) {
        expect(entitlements, contains('<string>applinks:$host</string>'));
      }
    });

    test('association file claims /public/* but not collections', () {
      final aasa =
          jsonDecode(
                File(
                  '.well-known/apple-app-site-association',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final applinks = aasa['applinks'] as Map<String, dynamic>;
      final detail = (applinks['details'] as List).single as Map;
      expect(applinks['apps'], isEmpty);
      expect(detail['appID'], 'ZYJ4TZX4UU.nl.surf.edubadges');
      // The first matching component wins, so the exclusion must come first.
      expect(detail['components'], [
        {'/': '/public/collections/*', 'exclude': true},
        {'/': '/public/*'},
      ]);
    });
  });

  group('assetlinks.json', () {
    test('names the Android package the manifest builds', () {
      final links =
          jsonDecode(File('.well-known/assetlinks.json').readAsStringSync())
              as List;
      final target = (links.single as Map)['target'] as Map;
      expect(target['package_name'], 'nl.surf.edubadges');
    });
  });
}
