import 'package:edubadges/flavors.dart';
import 'package:flutter/foundation.dart';

/// Compile-time dev auth token passed via `--dart-define=DEV_ACCESS_TOKEN=...`.
///
/// Only applied in debug builds and non-prod flavors. Never use in production.
class DevAuthConfig {
  DevAuthConfig._();

  static const String accessTokenDefineKey = 'DEV_ACCESS_TOKEN';

  static const String _accessToken = String.fromEnvironment(
    accessTokenDefineKey,
  );

  static String? get accessToken {
    if (_accessToken.isEmpty) {
      return null;
    }
    return _normalizeToken(_accessToken);
  }

  static bool get shouldApplyDevAccessToken {
    final String? token = accessToken;
    if (token == null || token.isEmpty) {
      return false;
    }
    if (!kDebugMode) {
      return false;
    }
    if (F.appFlavor == Flavor.prod) {
      return false;
    }
    return true;
  }

  static String _normalizeToken(String raw) {
    final trimmed = raw.trim();
    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }
    return trimmed;
  }
}
