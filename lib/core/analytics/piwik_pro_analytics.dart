import 'package:edubadges/core/analytics/piwik_pro_tracker.dart';
import 'package:edubadges/core/utils/logger.dart';

/// Piwik PRO analytics, enabled per flavor through `ENABLE_ANALYTICS`.
///
/// The platform-specific work lives in [PiwikProTracker]: the native SDK on
/// Android/iOS, Piwik PRO's JavaScript client on web. Tracking is anonymous and
/// cookieless on both.
class PiwikProAnalytics {
  PiwikProAnalytics._();

  static final PiwikProAnalytics instance = PiwikProAnalytics._();

  static const PiwikProTracker _tracker = PiwikProTracker();

  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  Future<void> initialize({
    required String baseUrl,
    required String siteId,
    required bool enabled,
  }) async {
    _isEnabled = enabled && baseUrl.isNotEmpty && siteId.isNotEmpty;
    if (!_isEnabled) {
      return;
    }
    try {
      await _tracker.initialize(baseUrl: baseUrl, siteId: siteId);
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
      await _tracker.trackScreen(screenName);
    } catch (error, stackTrace) {
      logger.w(
        'Failed to track Piwik PRO screen view',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
