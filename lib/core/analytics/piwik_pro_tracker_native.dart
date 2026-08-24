import 'package:flutter_piwikpro/flutter_piwikpro.dart';

/// Piwik PRO tracking backed by the native Android/iOS SDK.
class PiwikProTracker {
  const PiwikProTracker();

  Future<void> initialize({
    required String baseUrl,
    required String siteId,
  }) async {
    final FlutterPiwikPro piwik = FlutterPiwikPro.sharedInstance;
    await piwik.configureTracker(baseURL: baseUrl, siteId: siteId);
    await piwik.setAnonymizationState(true);
  }

  Future<void> trackScreen(String screenName) {
    return FlutterPiwikPro.sharedInstance.trackScreen(screenName: screenName);
  }
}
