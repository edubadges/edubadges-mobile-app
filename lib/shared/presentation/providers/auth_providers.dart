import 'package:edubadges/shared/data/datasources/auth_local_datasource.dart';
import 'package:edubadges/shared/data/repositories/auth_repository.dart';
import 'package:edubadges/shared/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data source and repository providers (unchanged)
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref, ref.read(authLocalDataSourceProvider));
});

// Modern async auth state provider
final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Initial load: check if user is logged in
    return await ref.read(authRepositoryProvider).isLoggedIn();
  }

  Future<void> login() async {
    state = const AsyncLoading(); // Show loading state
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login();
      return true;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      return false;
    });
  }
}