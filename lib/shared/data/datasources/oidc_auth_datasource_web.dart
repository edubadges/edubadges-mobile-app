import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/datasources/secure_token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:web/web.dart' as web;

/// Web implementation of the OIDC flow using the Authorization Code flow with
/// PKCE, executed entirely in the browser (public client, no secret).
///
/// `flutter_appauth` (used on mobile) has no web support, so the browser
/// redirect and token exchange are handled here. The SURFconext token endpoint
/// allows CORS for the app origin, so the code→token exchange runs client-side.
class OidcAuthDataSource {
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();
  final FlutterSecureStorage _pkceStorage = const FlutterSecureStorage();
  Fresh<OAuth2Token>? _fresh;
  Future<OAuth2Token>? _refreshInFlight;

  static const String _verifierKey = 'oidc_pkce_verifier';
  static const String _stateKey = 'oidc_pkce_state';

  final List<String> _scopes = ['openid', 'eduid.nl/links', 'offline_access'];

  String get _issuer => EnvironmentConfig.instance.openIdUrl;
  String get _clientId => EnvironmentConfig.instance.openIdClientId;
  String get _authorizeEndpoint => '$_issuer/authorize';
  String get _tokenEndpoint => '$_issuer/token';

  /// Redirect URI must exactly match what is registered on SurfConext for the
  /// web client (the app origin with a trailing slash), e.g.
  /// `https://dev.edubadges.preprod.aws.coffeeit.nl/` or `http://localhost:8080/`.
  String get _redirectUri => '${Uri.base.origin}/';

  void setFresh(Fresh<OAuth2Token>? fresh) {
    _fresh = fresh;
  }

  /// Starts the login by redirecting the browser to the authorization endpoint.
  ///
  /// This navigates the whole page away, so the returned future never
  /// completes; the flow resumes on the next app load via
  /// [completeLoginFromRedirect].
  Future<void> login({bool addAcrValues = false}) async {
    final String verifier = _generateRandomString(64);
    final String challenge = _codeChallenge(verifier);
    final String state = _generateRandomString(32);

    await _pkceStorage.write(key: _verifierKey, value: verifier);
    await _pkceStorage.write(key: _stateKey, value: state);

    final Map<String, String> params = {
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': _scopes.join(' '),
      'state': state,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    };
    if (addAcrValues) {
      params['acr_values'] = 'https://eduid.nl/trust/validate-names';
    } else {
      params['prompt'] = 'login';
    }

    final String authUrl = Uri.parse(
      _authorizeEndpoint,
    ).replace(queryParameters: params).toString();

    logger.i('Auth(web): redirecting to authorization endpoint');
    web.window.location.href = authUrl;

    // Suspend until the page unloads so callers don't continue the flow.
    await Completer<void>().future;
  }

  /// Completes login after SurfConext redirects back with `?code=...&state=...`.
  ///
  /// Returns `true` when a token was successfully obtained and stored.
  Future<bool> completeLoginFromRedirect(Uri uri) async {
    final String? error = uri.queryParameters['error'];
    if (error != null) {
      logger.e('Auth(web): authorization error: $error');
      await _clearPkce();
      return false;
    }

    final String? code = uri.queryParameters['code'];
    final String? returnedState = uri.queryParameters['state'];
    if (code == null || code.isEmpty) {
      return false;
    }

    final String? verifier = await _pkceStorage.read(key: _verifierKey);
    final String? storedState = await _pkceStorage.read(key: _stateKey);
    if (verifier == null || storedState == null || storedState != returnedState) {
      logger.e('Auth(web): state mismatch or missing PKCE verifier');
      await _clearPkce();
      return false;
    }

    try {
      final Response<dynamic> response = await _authDio.post(
        _tokenEndpoint,
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _redirectUri,
          'client_id': _clientId,
          'code_verifier': verifier,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      await _persistTokenResponse(response.data as Map<String, dynamic>);
      await _clearPkce();
      logger.i('Auth(web): login successful, token stored');
      return true;
    } catch (e) {
      logger.e('Auth(web): token exchange failed', error: e);
      await _clearPkce();
      return false;
    }
  }

  static final Dio _authDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<void> _persistTokenResponse(
    Map<String, dynamic> data, {
    String? fallbackRefreshToken,
  }) async {
    final String? accessToken = data['access_token'] as String?;
    if (accessToken == null) {
      throw Exception('Token response did not contain an access token');
    }
    final String? refreshToken =
        data['refresh_token'] as String? ?? fallbackRefreshToken;
    final OAuth2Token token = OAuth2Token(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await _tokenStorage.write(token);
    await _tokenStorage.writeExpiration(
      _expirationFrom(data['expires_in']),
      accessToken: accessToken,
    );
    await _fresh?.setToken(token);
  }

  DateTime? _expirationFrom(dynamic expiresIn) {
    final int? seconds = expiresIn is int
        ? expiresIn
        : (expiresIn is String ? int.tryParse(expiresIn) : null);
    if (seconds == null) {
      return null;
    }
    return DateTime.now().add(Duration(seconds: seconds));
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

    if (token == null) {
      return null;
    }
    if (isExpired || forceRefresh) {
      logger.i('Auth(web): token needs a refresh');
      if (token.refreshToken == null) {
        logger.w('Auth(web): no refresh token available');
        return null;
      }
      try {
        await refreshToken();
      } catch (_) {
        return null;
      }
      final refreshedToken = await _tokenStorage.read();
      return refreshedToken?.accessToken;
    }

    return token.accessToken;
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
      logger.w('Auth(web): no refresh token available');
      throw Exception('No refresh token available');
    }
    try {
      logger.i('Auth(web): refreshing token via OIDC');
      final Response<dynamic> response = await _authDio.post(
        _tokenEndpoint,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': token!.refreshToken,
          'client_id': _clientId,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      await _persistTokenResponse(
        response.data as Map<String, dynamic>,
        fallbackRefreshToken: token.refreshToken,
      );
      final newToken = await _tokenStorage.read();
      if (newToken == null) {
        throw Exception('Token refresh did not produce a token');
      }
      return newToken;
    } catch (e) {
      if (_isPermanentAuthFailure(e)) {
        logger.e(
          'Auth(web): refresh token rejected, clearing session',
          error: e,
        );
        await logout();
      } else {
        logger.w('Auth(web): token refresh failed, keeping session', error: e);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    logger.i('Auth(web): logout called');
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

  /// Whether [error] means the stored grant can never succeed again.
  ///
  /// The token endpoint rejects a dead grant with an OAuth error code; offline
  /// browsers, timeouts and 5xx responses are transient, and clearing tokens
  /// for those logs the user out whenever a refresh runs at a bad moment.
  static bool _isPermanentAuthFailure(Object error) {
    if (error is! DioException) {
      return false;
    }
    final int? statusCode = error.response?.statusCode;
    if (statusCode != 400 && statusCode != 401) {
      return false;
    }
    final dynamic data = error.response?.data;
    final String? code = data is Map ? data['error'] as String? : null;
    return code == 'invalid_grant' ||
        code == 'invalid_client' ||
        code == 'unauthorized_client' ||
        code == 'invalid_scope';
  }

  Future<void> _clearPkce() async {
    await _pkceStorage.delete(key: _verifierKey);
    await _pkceStorage.delete(key: _stateKey);
  }

  String _generateRandomString(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final Random random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _codeChallenge(String verifier) {
    final Digest digest = sha256.convert(ascii.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
