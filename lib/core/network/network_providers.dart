import 'package:aroma_networking/aroma_networking.dart';
import 'package:dio/dio.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/datasources/oidc_auth_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final oidcAuthDataSourceProvider = Provider<OidcAuthDataSource>((ref) {
  return OidcAuthDataSource();
});

final networkConfigProvider = Provider<AromaNetworkConfig>((ref) {
  final oidcAuth = ref.watch(oidcAuthDataSourceProvider);
  return AromaNetworkConfig(
    baseUrl: EnvironmentConfig.instance.apiUrl,
    getAccessToken: oidcAuth.getAccessToken,
    onUnauthorized: oidcAuth.logout,
    logger: logger,
  );
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(networkConfigProvider);
  final dio = config.createDio();
  dio.options.headers['x-requested-with'] = 'mobile';
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
