import 'package:edubadges/core/constants/environment_config.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final EnvironmentConfig config = EnvironmentConfig.instance;
final String issuer = config.openIdUrl;
final String clientId = config.openIdClientId;
const String redirectUri = 'edubadges://oauth/callback';

class OidcAuthDataSource {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expirationKey = 'access_token_expiration';

  final List<String> _scopes = ['openid', 'eduid.nl/links'];

  /// Perform login – called when app opens if no valid token
  Future<void> login({bool addAcrValues = false}) async {
    try {
      final Map<String, String> additionalParameters = {};
      List<String>? promptValues; // Default to null

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
        await _saveTokens(
          result.accessToken!,
          result.refreshToken,
          result.accessTokenExpirationDateTime,
          result.idToken,
        );
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
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (expirationDateTime != null) {
      await _secureStorage.write(
        key: _expirationKey,
        value: expirationDateTime.toIso8601String(),
      );
    } else {
      await _secureStorage.delete(key: _expirationKey);
    }
  }

  /// Get valid access token – auto-refreshes if possible
  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    final String? token = await _secureStorage.read(key: _accessTokenKey);
    final String? expirationIso = await _secureStorage.read(key: _expirationKey);

    DateTime? expirationDateTime;
    if (expirationIso != null) {
      expirationDateTime = DateTime.tryParse(expirationIso);
    }

    final bool isExpired = expirationDateTime != null &&
        expirationDateTime.isBefore(DateTime.now().subtract(const Duration(minutes: 5)));

    if (token == null || isExpired || forceRefresh) {
      await _refreshTokenIfPossible();
      return await _secureStorage.read(key: _accessTokenKey);
    }

    return token;
  }

  Future<void> _refreshTokenIfPossible() async {
    final String? refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null) return;

    try {
      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUri,
          issuer: issuer,
          refreshToken: refreshToken,
          scopes: _scopes,
        ),
      );

      if (result.accessToken != null) {
        await _saveTokens(
          result.accessToken!,
          result.refreshToken,
          result.accessTokenExpirationDateTime,
          result.idToken,
        );
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  /// Helper: Check if user is authenticated (valid token)
  Future<bool> isAuthenticated() async {
    final String? token = await getAccessToken();
    return token != null;
  }
}