import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:edubadges/shared/data/datasources/notification_permission_local_datasource.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
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

  /// Invalidates all user-dependent and network providers so no stale or
  /// sensitive state persists across logout or when a new user logs in.
  Future<void> _clearUserDependentState() async {
    await ref
        .read(notificationPermissionLocalDataSourceProvider)
        .clearDeclinedPrompt();
    ref.invalidate(notificationPermissionPromptDeclinedProvider);
    ref.invalidate(shouldShowNotificationPermissionPromptProvider);
    clearGeneralTermsMarkdownUrlCache(ref);
    ref.invalidate(profileProvider, asReload: true);
    ref.invalidate(badgesOverviewProvider, asReload: true);
    ref.invalidate(collectionsProvider, asReload: true);
    ref.invalidate(catalogProvider, asReload: true);
    ref.invalidate(loginStatusProvider, asReload: true);
    ref.invalidate(badgeDetailsProvider, asReload: true);
    ref.invalidate(badgeDetailsModelProvider, asReload: true);
  }

  /// Perform login (authorization code flow)
  Future<void> login() async {
    state = const AsyncLoading();
    final loginRepository = ref.read(loginRepositoryProvider);

    try {
      await _clearUserDependentState();
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
    await _clearUserDependentState();
    state = const AsyncData(false);
  }
}
