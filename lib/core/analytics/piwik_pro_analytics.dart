import 'package:edubadges/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_piwikpro/flutter_piwikpro.dart';

class PiwikProAnalytics {
  PiwikProAnalytics._();

  static final PiwikProAnalytics instance = PiwikProAnalytics._();

  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  Future<void> initialize({
    required String baseUrl,
    required String siteId,
    required bool enabled,
  }) async {
    _isEnabled = enabled && !kIsWeb;
    if (!_isEnabled) {
      return;
    }
    try {
      final FlutterPiwikPro piwik = FlutterPiwikPro.sharedInstance;
      await piwik.configureTracker(baseURL: baseUrl, siteId: siteId);
      await piwik.setAnonymizationState(true);
    } catch (error, stackTrace) {
      _isEnabled = false;
      logger.w(
        'Failed to initialize Piwik PRO analytics',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> trackScreen(String screenName) async {
    if (!_isEnabled) {
      return;
    }
    try {
      await FlutterPiwikPro.sharedInstance.trackScreen(screenName: screenName);
    } catch (error, stackTrace) {
      logger.w(
        'Failed to track Piwik PRO screen view',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
