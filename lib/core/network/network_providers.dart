import 'package:dio/dio.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/network_config.dart';
import 'package:edubadges/core/network/network_info.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/datasources/oidc_auth_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(networkConfigProvider);
  final oidcAuth = ref.watch(oidcAuthDataSourceProvider);
  
  final dio = config.createDio();
  dio.options.headers['x-requested-with'] = 'mobile';
  
  oidcAuth.setFresh(config.fresh);
  
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
