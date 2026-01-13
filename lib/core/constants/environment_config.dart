class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();

  factory EnvironmentConfig({
    required String apiUrl,
    required bool enableAnalytics,
    required bool enableCrashlytics,
  }) {
    if (_instance.isInitialized) {
      throw StateError('EnvironmentConfig has already been initialized.');
    }
    _instance.init(
      apiUrl: apiUrl,
      enableAnalytics: enableAnalytics,
      enableCrashlytics: enableCrashlytics,
    );
    return _instance;
  }

  EnvironmentConfig._internal();

  static EnvironmentConfig get instance => _instance;

  late final String _apiUrl;
  late final bool _enableAnalytics;
  late final bool _enableCrashlytics;
  bool isInitialized = false;

  void init({
    required String apiUrl,
    required bool enableAnalytics,
    required bool enableCrashlytics,
  }) {
    if (isInitialized) {
      throw StateError('EnvironmentConfig has already been initialized.');
    }
    _apiUrl = apiUrl;
    _enableAnalytics = enableAnalytics;
    _enableCrashlytics = enableCrashlytics;
    isInitialized = true;
  }

  String get apiUrl => _apiUrl;
  bool get enableAnalytics => _enableAnalytics;
  bool get enableCrashlytics => _enableCrashlytics;
}
