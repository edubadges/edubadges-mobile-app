import 'package:flutter/foundation.dart';

enum AppPlatformType { ios, android, web }

class PlatformInfo {
  PlatformInfo._();

  static bool get isWeb => kIsWeb;

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static AppPlatformType get platformType {
    if (kIsWeb) {
      return AppPlatformType.web;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppPlatformType.ios;
    }
    return AppPlatformType.android;
  }

  // Temporary: API expects mobile platform headers on all clients.
  static String get platformHeaderValue => 'mobile';

  static String get requestedWithHeaderValue => 'mobile';

  static String get platformDisplayName {
    switch (platformType) {
      case AppPlatformType.ios:
        return 'iOS';
      case AppPlatformType.android:
        return 'Android';
      case AppPlatformType.web:
        return 'Web';
    }
  }

  static bool get useCupertinoDialog => isIOS;

  /// Whether in-app back buttons should be shown. On web the browser's own
  /// back navigation is used instead, so in-app back buttons are hidden.
  static bool get showInAppBackButton => !isWeb;
}
