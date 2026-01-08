import 'package:edubadges/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthLocalDataSource {
  Future<bool> isLoggedIn();
  Future<void> login();
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Ref ref;

  AuthLocalDataSourceImpl(this.ref);

  static const String _keyIsLoggedIn = 'is_logged_in';

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  @override
  Future<void> login() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  @override
  Future<void> logout() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}