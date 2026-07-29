import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';

class SecureTokenStorage implements TokenStorage<OAuth2Token> {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'oauth2_token';
  static const String _expirationKey = 'oauth2_token_expiration';

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> delete() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expirationKey);
  }

  @override
  Future<OAuth2Token?> read() async {
    final tokenJson = await _storage.read(key: _tokenKey);
    if (tokenJson == null) return null;
    
    try {
      final Map<String, dynamic> data = json.decode(tokenJson) as Map<String, dynamic>;
      return OAuth2Token(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String?,
        tokenType: data['tokenType'] as String? ?? 'bearer',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> write(OAuth2Token token) async {
    final data = {
      'accessToken': token.accessToken,
      'refreshToken': token.refreshToken,
      'tokenType': token.tokenType,
    };
    await _storage.write(key: _tokenKey, value: json.encode(data));
  }
  
  /// Stores when the access token expires.
  ///
  /// When the authorization server omits `expires_in`, falls back to the `exp`
  /// claim of [accessToken]. Without a known expiry every read counts as
  /// expired, which triggers a refresh on each call.
  Future<void> writeExpiration(
    DateTime? expirationDateTime, {
    String? accessToken,
  }) async {
    final expiration = expirationDateTime ??
        (accessToken != null ? _expirationFromJwt(accessToken) : null);

    if (expiration != null) {
      await _storage.write(
        key: _expirationKey,
        value: expiration.toIso8601String(),
      );
    } else {
      await _storage.delete(key: _expirationKey);
    }
  }

  /// Returns null for opaque tokens, which the OAuth 2 spec permits.
  static DateTime? _expirationFromJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map) return null;

      final exp = payload['exp'];
      if (exp is! num) return null;

      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      ).toLocal();
    } catch (e) {
      return null;
    }
  }
  
  Future<DateTime?> readExpiration() async {
    final expirationIso = await _storage.read(key: _expirationKey);
    if (expirationIso == null) return null;
    return DateTime.tryParse(expirationIso);
  }
  
  /// Checks expiration with 5-minute buffer
  Future<bool> isExpired() async {
    final expiration = await readExpiration();
    if (expiration == null) return true;
    return DateTime.now().isAfter(expiration.subtract(const Duration(minutes: 5)));
  }
}