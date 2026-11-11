import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();

  factory EnvironmentConfig({
    required String apiUrl,
    required String openIdUrl,
    required String openIdClientId,
    String openIdWebClientId = '',
    required bool enableAnalytics,
    required bool enableCrashlytics,
    required String publicCollectionBaseUrl,
    required String piwikProBaseUrl,
    required String piwikProSiteId,
  }) {
    if (_instance.isInitialized) {
      throw StateError('EnvironmentConfig has already been initialized.');
    }
    _instance.init(
      apiUrl: apiUrl,
      openIdUrl: openIdUrl,
      openIdClientId: openIdClientId,
      openIdWebClientId: openIdWebClientId,
      enableAnalytics: enableAnalytics,
      enableCrashlytics: enableCrashlytics,
      publicCollectionBaseUrl: publicCollectionBaseUrl,
      piwikProBaseUrl: piwikProBaseUrl,
      piwikProSiteId: piwikProSiteId,
    );
    return _instance;
  }

  EnvironmentConfig._internal();

  /// A separate, uninitialised instance, so a test can configure one without
  /// touching the app-wide singleton.
  @visibleForTesting
  EnvironmentConfig.detached() : this._internal();

  static EnvironmentConfig get instance => _instance;

  late final String _apiUrl;
  late final String _openIdUrl;
  late final String _openIdClientId;
  late final String _openIdWebClientId;
  late final bool _enableAnalytics;
  late final bool _enableCrashlytics;
  late final String _publicCollectionBaseUrl;
  late final String _piwikProBaseUrl;
  late final String _piwikProSiteId;
  bool isInitialized = false;

  void init({
    required String apiUrl,
    required String openIdUrl,
    required String openIdClientId,
    String openIdWebClientId = '',
    required bool enableAnalytics,
    required bool enableCrashlytics,
    required String publicCollectionBaseUrl,
    required String piwikProBaseUrl,
    required String piwikProSiteId,
  }) {
    if (isInitialized) {
      throw StateError('EnvironmentConfig has already been initialized.');
    }
    _apiUrl = apiUrl;
    _openIdUrl = openIdUrl;
    _openIdClientId = openIdClientId;
    _openIdWebClientId = openIdWebClientId.trim();
    _enableAnalytics = enableAnalytics;
    _enableCrashlytics = enableCrashlytics;
    _publicCollectionBaseUrl = publicCollectionBaseUrl;
    _piwikProBaseUrl = piwikProBaseUrl;
    _piwikProSiteId = piwikProSiteId;
    isInitialized = true;
  }

  String get apiUrl => _apiUrl;
  String get openIdUrl => _openIdUrl;
  String get openIdClientId => _openIdClientId;

  /// The SURFconext client the web build logs in with.
  ///
  /// Web has its own client so it can have a shorter refresh-token lifetime
  /// than the mobile apps: a browser on a shared computer should not stay
  /// signed in for a year. Until that client is set in `.env.<flavor>`, web
  /// keeps using the mobile client.
  String get webOpenIdClientId =>
      _openIdWebClientId.isNotEmpty ? _openIdWebClientId : _openIdClientId;
  bool get enableAnalytics => _enableAnalytics;
  bool get enableCrashlytics => _enableCrashlytics;
  String get publicCollectionBaseUrl => _publicCollectionBaseUrl;
  String get piwikProBaseUrl => _piwikProBaseUrl;
  String get piwikProSiteId => _piwikProSiteId;
}
