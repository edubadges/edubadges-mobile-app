import 'package:edubadges/core/constants/dev_auth_config.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/datasources/oidc_auth_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_dio/fresh_dio.dart';

const Duration _devTokenExpiration = Duration(hours: 24);

/// Seeds [SecureTokenStorage] and Dio [Fresh] when [DevAuthConfig] supplies a token.
Future<void> applyDevAccessTokenIfDefined(ProviderContainer container) async {
  if (!DevAuthConfig.shouldApplyDevAccessToken) {
    return;
  }
  final String accessToken = DevAuthConfig.accessToken!;
  container.read(dioProvider);
  final OidcAuthDataSource oidcAuth = container.read(oidcAuthDataSourceProvider);
  final Fresh<OAuth2Token>? fresh =
      container.read(networkConfigProvider).fresh;
  final OAuth2Token token = OAuth2Token(accessToken: accessToken);
  await oidcAuth.tokenStorage.write(token);
  await oidcAuth.tokenStorage.writeExpiration(
    DateTime.now().add(_devTokenExpiration),
  );
  if (fresh != null) {
    await fresh.setToken(token);
  }
  logger.i(
    'Dev auth: applied ${DevAuthConfig.accessTokenDefineKey} for local development',
  );
}
