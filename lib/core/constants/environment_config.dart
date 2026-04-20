class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();

  factory EnvironmentConfig({
    required String apiUrl,
    required String openIdUrl,
    required String openIdClientId,
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
      enableAnalytics: enableAnalytics,
      enableCrashlytics: enableCrashlytics,
      publicCollectionBaseUrl: publicCollectionBaseUrl,
      piwikProBaseUrl: piwikProBaseUrl,
      piwikProSiteId: piwikProSiteId,
    );
    return _instance;
  }

  EnvironmentConfig._internal();

  static EnvironmentConfig get instance => _instance;

  late final String _apiUrl;
  late final String _openIdUrl;
  late final String _openIdClientId;
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
  bool get enableAnalytics => _enableAnalytics;
  bool get enableCrashlytics => _enableCrashlytics;
  String get publicCollectionBaseUrl => _publicCollectionBaseUrl;
  String get piwikProBaseUrl => _piwikProBaseUrl;
  String get piwikProSiteId => _piwikProSiteId;
}
