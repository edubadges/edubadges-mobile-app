import 'package:dio/dio.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/interceptors/general_terms_interceptor.dart';
import 'package:edubadges/core/network/network_config.dart';
import 'package:edubadges/core/network/network_info.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/features/general_terms/presentation/navigation/general_terms_navigation.dart';
import 'package:edubadges/shared/data/datasources/oidc_auth_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final oidcAuthDataSourceProvider = Provider<OidcAuthDataSource>((ref) {
  return OidcAuthDataSource();
});

final networkConfigProvider = Provider<NetworkConfig>((ref) {
  final oidcAuth = ref.watch(oidcAuthDataSourceProvider);
  return NetworkConfig(
    baseUrl: EnvironmentConfig.instance.apiUrl,
    tokenStorage: oidcAuth.tokenStorage,
    onRefreshToken: oidcAuth.refreshToken,
    logger: logger,
  );
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// Sets the headers that tell the API which language to answer in.
///
/// `Accept-Language` is CORS-safelisted, so web sends it too. Web browsers
/// preflight custom headers and the API only allows a fixed CORS header list,
/// so `x-language` stays native-only.
void _applyLanguageHeaders(Map<String, dynamic> headers, AppLanguage language) {
  headers['Accept-Language'] = language.code;
  if (!kIsWeb) {
    headers['x-language'] = language.code;
  }
}

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(networkConfigProvider);
  final oidcAuth = ref.watch(oidcAuthDataSourceProvider);

  final dio = config.createDio();
  dio.options.headers['x-requested-with'] = PlatformInfo.requestedWithHeaderValue;

  // Listened to rather than watched: a language switch must not rebuild Dio.
  // That would replace the token-refreshing interceptor and rebuild every
  // provider built on the API client, the login and auth ones included.
  _applyLanguageHeaders(dio.options.headers, ref.read(appLanguageProvider));
  ref.listen<AppLanguage>(
    appLanguageProvider,
    (_, language) => _applyLanguageHeaders(dio.options.headers, language),
  );

  dio.interceptors.insert(0, InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Web browsers preflight custom headers; the API only allows a fixed CORS
      // header list (no x-platform / x-app-version / x-language).
      if (!kIsWeb) {
        final packageInfo = await ref.read(packageInfoProvider.future);
        options.headers['x-platform'] = PlatformInfo.platformHeaderValue;
        options.headers['x-app-version'] = packageInfo.version;
      }
      handler.next(options);
    },
  ));

  oidcAuth.setFresh(config.fresh);

  dio.interceptors.add(
    GeneralTermsInterceptor(
      onTermsRequired: () => navigateToGeneralTermsIfNeeded(dio),
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(networkConfigProvider);
  final dio = ref.watch(dioProvider);
  return ApiClient(baseUrl: config.baseUrl, dio: dio);
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});
