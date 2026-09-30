import 'dart:async';

import 'package:edubadges/core/auth/oidc_error_classifier.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/datasources/secure_token_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:fresh_dio/fresh_dio.dart';

final EnvironmentConfig config = EnvironmentConfig.instance;
final String issuer = config.openIdUrl;
final String clientId = config.openIdClientId;

// Registered on both SurfConext clients. The single slash is the RFC 8252 form
// for a private-use scheme (no authority); the SP Dashboard rejects the legacy
// `edubadges://` as "not a proper URL".
const String redirectUri = 'mobile.edubadges:/oauth/callback';

class OidcAuthDataSource {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();
  Fresh<OAuth2Token>? _fresh;
  Future<OAuth2Token>? _refreshInFlight;
  final StreamController<void> _sessionExpired =
      StreamController<void>.broadcast();

  final List<String> _scopes = ['openid', 'eduid.nl/links', 'offline_access'];

  /// Fires when SurfConext rejected the refresh token and the session was
  /// cleared, as opposed to the user logging out. The app then has to return
  /// to the login screen.
  Stream<void> get sessionExpired => _sessionExpired.stream;

  void setFresh(Fresh<OAuth2Token>? fresh) {
    _fresh = fresh;
  }

  /// Mobile completes the flow inline via [login]; there is no browser redirect
  /// to finish. Present only so the shared web bootstrap type-checks against the
  /// conditional-export barrel (never invoked on mobile).
  Future<bool> completeLoginFromRedirect(Uri uri) async => false;

  Future<void> login({bool addAcrValues = false}) async {
    try {
      final Map<String, String> additionalParameters = {};
      List<String>? promptValues;

      if (addAcrValues) {
        additionalParameters['acr_values'] =
            'https://eduid.nl/trust/validate-names';
      } else {
        promptValues = ['login'];
      }

      final AuthorizationTokenResponse result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              clientId,
              redirectUri,
              issuer: issuer,
              scopes: _scopes,
              promptValues: promptValues,
              additionalParameters: additionalParameters,
            ),
          );

      if (result.accessToken != null) {
        final token = OAuth2Token(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken,
        );

        await _saveTokens(
          result.accessToken!,
          result.refreshToken,
          result.accessTokenExpirationDateTime,
          result.idToken,
        );

        logger.i('Auth: Notifying fresh about new token');
        if (_fresh != null) {
          await _fresh!.setToken(token);
          logger.i('Auth: Token set in fresh');

          final storedToken = await _tokenStorage.read();
          logger.i(
            'Auth: Verified token in storage - accessToken exists: ${storedToken?.accessToken != null}',
          );
        } else {
          logger.w('Auth: Fresh instance is null, cannot set token!');
        }
        logger.i('Auth: Login successful, token set');
      } else {
        throw Exception('Login failed: no token received');
      }
    } catch (e, stackTrace) {
      if (isNetworkAuthFailure(e)) {
        // Surfaces as a NetworkFailure, so the login screen can say SurfConext
        // is unreachable instead of the login silently doing nothing.
        throw NetworkException(
          message: 'SurfConext could not be reached',
          code: ErrorCodes.networkError,
          originalError: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<void> _saveTokens(
    String accessToken,
    String? refreshToken,
    DateTime? expirationDateTime,
    String? idToken,
  ) async {
    final oauth2token = OAuth2Token(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _tokenStorage.write(oauth2token);
    await _fresh?.setToken(oauth2token);
    await _tokenStorage.writeExpiration(
      expirationDateTime,
      accessToken: accessToken,
    );
  }

  Future<void> refreshTokenIfExpired() async {
    final isExpired = await _tokenStorage.isExpired();
    if (!isExpired) {
      return;
    }
    final token = await _tokenStorage.read();
    if (token?.refreshToken == null) {
      return;
    }
    try {
      await refreshToken();
    } catch (_) {
      // refreshToken logs out and rethrows; callers may continue without token.
    }
  }

  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    final token = await _tokenStorage.read();
    final isExpired = await _tokenStorage.isExpired();

    if (token == null || isExpired || forceRefresh) {
      logger.i('Auth: Token needs a refresh');
      await _refreshTokenIfPossible();
      final refreshedToken = await _tokenStorage.read();
      return refreshedToken?.accessToken;
    }

    return token.accessToken;
  }

  Future<void> _refreshTokenIfPossible() async {
    final token = await _tokenStorage.read();
    if (token?.refreshToken == null) {
      logger.w('Auth: No refresh token available');
      return;
    }
    try {
      await refreshToken();
    } catch (_) {
      // refreshToken already logged out and logged the error.
    }
  }

  Future<OAuth2Token> refreshToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }
    final refreshFuture = _performOidcRefresh();
    _refreshInFlight = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      if (identical(_refreshInFlight, refreshFuture)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<OAuth2Token> _performOidcRefresh() async {
    final token = await _tokenStorage.read();
    if (token?.refreshToken == null) {
      logger.w('Auth: No refresh token available');
      throw Exception('No refresh token available');
    }
    try {
      logger.i('Auth: Refreshing token via OIDC');
      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUri,
          issuer: issuer,
          refreshToken: token!.refreshToken,
          scopes: _scopes,
        ),
      );
      if (result.accessToken != null) {
        logger.i(
          'Auth: Token refresh successful '
          '(server returned refresh_token: ${result.refreshToken != null}, '
          'expires: ${result.accessTokenExpirationDateTime})',
        );
        // SurfConext only returns `refresh_token` when rotation is enabled.
        // Storing null on the responses that omit it would strand the session
        // at the next expiry, so fall back to the token we just used.
        final String? refreshToken = result.refreshToken ?? token.refreshToken;
        final newToken = OAuth2Token(
          accessToken: result.accessToken!,
          refreshToken: refreshToken,
        );
        await _saveTokens(
          result.accessToken!,
          refreshToken,
          result.accessTokenExpirationDateTime,
          result.idToken,
        );
        return newToken;
      } else {
        logger.e('Auth: Token refresh failed - no access token received');
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      if (isPermanentAuthFailure(e)) {
        logger.e('Auth: Refresh token rejected, clearing session', error: e);
        await logout();
        _sessionExpired.add(null);
      } else {
        logger.w('Auth: Token refresh failed, keeping session', error: e);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    logger.e('Auth: Logout called');
    await _fresh?.clearToken();
    await _tokenStorage.delete();
  }

  Future<bool> isAuthenticated() async {
    final String? token = await getAccessToken();
    return token != null;
  }

  SecureTokenStorage get tokenStorage {
    return _tokenStorage;
  }
}
