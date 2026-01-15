import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final loginRepository = ref.read(loginRepositoryProvider);
    final result = await loginRepository.isLoggedIn();
    return result.getOrElse(() => false);
  }

  /// Perform login (authorization code flow)
  Future<void> login() async {
    state = const AsyncLoading();
    final loginRepository = ref.read(loginRepositoryProvider);

    try {
      await loginRepository.login();
      state = const AsyncData(true);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  /// Logout and clear tokens
  Future<void> logout() async {
    final loginRepository = ref.read(loginRepositoryProvider);
    await loginRepository.logout();
    state = const AsyncData(false);
  }
}
