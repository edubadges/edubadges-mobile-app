import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/datasources/oidc_auth_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

/// Completes the OIDC redirect when the browser returns from SurfConext with
/// `?code=...&state=...`.
///
/// Runs before `runApp` so the token is stored (and Dio's `Fresh` is seeded)
/// before the router evaluates authentication. After handling, the OAuth query
/// parameters are stripped from the URL and the app is pointed at the login
/// route so the existing post-login redirect logic (terms / main) takes over.
Future<void> completeWebLoginRedirect(ProviderContainer container) async {
  final Uri uri = Uri.base;
  final bool hasCode = uri.queryParameters.containsKey('code');
  final bool hasError = uri.queryParameters.containsKey('error');
  if (!hasCode && !hasError) {
    return;
  }

  // Ensure Dio (and therefore Fresh) is initialized so the new token propagates
  // to the network stack.
  container.read(dioProvider);
  final OidcAuthDataSource oidc = container.read(oidcAuthDataSourceProvider);

  try {
    await oidc.completeLoginFromRedirect(uri);
  } catch (e) {
    logger.e('Auth(web): failed to complete login redirect', error: e);
  } finally {
    web.window.history.replaceState(null, '', RoutePath.login);
  }
}
