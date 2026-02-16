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
  
  Future<void> writeExpiration(DateTime? expirationDateTime) async {
    if (expirationDateTime != null) {
      await _storage.write(
        key: _expirationKey,
        value: expirationDateTime.toIso8601String(),
      );
    } else {
      await _storage.delete(key: _expirationKey);
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