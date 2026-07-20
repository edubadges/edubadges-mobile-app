import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/datasources/secure_token_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';

class OidcAuthDataSource {
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();
  Fresh<OAuth2Token>? _fresh;

  void setFresh(Fresh<OAuth2Token>? fresh) {
    _fresh = fresh;
  }

  Future<void> login({bool addAcrValues = false}) async {
    throw UnsupportedError('Web login is not yet supported');
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
      // Web token refresh is not yet supported.
    }
  }

  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    final token = await _tokenStorage.read();
    final isExpired = await _tokenStorage.isExpired();

    if (token == null) {
      return null;
    }
    if (isExpired || forceRefresh) {
      logger.w('Auth: Token refresh on web is not yet supported');
      return null;
    }

    return token.accessToken;
  }

  Future<OAuth2Token> refreshToken() async {
    throw UnsupportedError('Web token refresh is not yet supported');
  }

  Future<void> logout() async {
    logger.i('Auth: Logout called');
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
