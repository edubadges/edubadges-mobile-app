import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/datasources/secure_token_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:fresh_dio/fresh_dio.dart';

final EnvironmentConfig config = EnvironmentConfig.instance;
final String issuer = config.openIdUrl;
final String clientId = config.openIdClientId;
const String redirectUri = 'edubadges://oauth/callback';

class OidcAuthDataSource {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();
  Fresh<OAuth2Token>? _fresh;

  final List<String> _scopes = ['openid', 'eduid.nl/links', 'offline_access'];

  void setFresh(Fresh<OAuth2Token>? fresh) {
    _fresh = fresh;
  }

  Future<void> login({bool addAcrValues = false}) async {
    try {
      final Map<String, String> additionalParameters = {};
      List<String>? promptValues;

      if (addAcrValues) {
        additionalParameters['acr_values'] = 'https://eduid.nl/trust/validate-names';
      } else {
        promptValues = ['login'];
      }

      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
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
          
          // Verify token was set
          final storedToken = await _tokenStorage.read();
          logger.i('Auth: Verified token in storage - accessToken exists: ${storedToken?.accessToken != null}');
        } else {
          logger.w('Auth: Fresh instance is null, cannot set token!');
        }
        logger.i('Auth: Login successful, token set');
      } else {
        throw Exception('Login failed: no token received');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveTokens(
      String accessToken,
      String? refreshToken,
      DateTime? expirationDateTime,
      String? idToken,
      ) async {
    await _tokenStorage.write(OAuth2Token(
      accessToken: accessToken,
      refreshToken: refreshToken,
    ));
    await _tokenStorage.writeExpiration(expirationDateTime);
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
      logger.w('Auth: No refresh token, logging out');
      return;
    }

    try {
      logger.i('Auth: Getting new auth token');

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
        logger.i('Auth: Got new access token');

        await _saveTokens(
          result.accessToken!,
          result.refreshToken,
          result.accessTokenExpirationDateTime,
          result.idToken,
        );
      } else {
        logger.e('Auth: Failed to get new access token (logging out)');
        await logout();
      }
    } catch (e) {
      logger.e('Auth: Failed to get new access token', error: e);
      await logout();
    }
  }

  Future<OAuth2Token> refreshToken() async {
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
        logger.i('Auth: Token refresh successful');

        final newToken = OAuth2Token(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken,
        );

        await _saveTokens(
          result.accessToken!,
          result.refreshToken,
          result.accessTokenExpirationDateTime,
          result.idToken,
        );

        return newToken;
      } else {
        logger.e('Auth: Token refresh failed - no access token received');
        await logout();
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      logger.e('Auth: Token refresh failed', error: e);
      await logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    logger.e('Auth: Logout called');
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