import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/features/login/domain/web_auto_login.dart';
import 'package:edubadges/features/login/presentation/providers/auto_login_providers.dart';
import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:edubadges/shared/data/datasources/notification_permission_local_datasource.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

/// Fires when SurfConext rejected the refresh token and the session was
/// cleared (see `OidcAuthDataSource.sessionExpired`).
final sessionExpiredEventsProvider = Provider<Stream<void>>((ref) {
  return ref.watch(oidcAuthDataSourceProvider).sessionExpired;
});

/// Whether the login screen should explain that the session expired.
///
/// Shown after a rejected refresh token ended the session; cleared on the next
/// login or logout.
final sessionExpiredNoticeProvider =
    NotifierProvider<SessionExpiredNoticeNotifier, bool>(
      SessionExpiredNoticeNotifier.new,
    );

class SessionExpiredNoticeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;

  void dismiss() => state = false;
}

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Listen before the first check: that check can refresh the token and find
    // the session already gone.
    final subscription = ref
        .read(sessionExpiredEventsProvider)
        .listen((_) => _handleSessionExpired());
    ref.onDispose(subscription.cancel);

    final loginRepository = ref.read(loginRepositoryProvider);
    final result = await loginRepository.isLoggedIn();
    return result.getOrElse(() => false);
  }

  /// SurfConext rejected the refresh token, so the tokens are gone. Return to
  /// the login screen instead of leaving the user on screens whose requests
  /// can only fail.
  Future<void> _handleSessionExpired() async {
    if (state.value ?? false) {
      logger.w('Auth: session expired, returning to login');
      await _clearUserDependentState();
      if (!ref.mounted) return;
      state = const AsyncData(false);
    }
    ref.read(sessionExpiredNoticeProvider.notifier).show();
  }

  /// Invalidates all user-dependent and network providers so no stale or
  /// sensitive state persists across logout or when a new user logs in.
  Future<void> _clearUserDependentState() async {
    ref.read(sessionExpiredNoticeProvider.notifier).dismiss();
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

  /// Perform login (authorization code flow).
  ///
  /// Returns `true` when login succeeded, `false` otherwise. Callers should
  /// rely on this return value instead of reading the provider after awaiting,
  /// to avoid touching `ref` on a possibly-unmounted widget.
  ///
  /// [replaceHistory] is for a login the app starts by itself on web: the page
  /// that started it should not stay in the browser history.
  Future<bool> login({bool replaceHistory = false}) async {
    state = const AsyncLoading();
    final loginRepository = ref.read(loginRepositoryProvider);

    try {
      await _clearUserDependentState();
      final result = await loginRepository.login(
        replaceHistory: replaceHistory,
      );
      return result.fold(
        (failure) {
          logger.e('Login failed: ${failure.message}');
          state = AsyncError(failure, StackTrace.current);
          return false;
        },
        (_) {
          state = const AsyncData(true);
          return true;
        },
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  /// Logout and clear tokens
  Future<void> logout() async {
    // Set before the state flips to logged out, so the login page the router
    // shows next already knows not to send the user straight back to eduID.
    ref
        .read(autoLoginSuppressionProvider.notifier)
        .suppress(AutoLoginSuppression.loggedOut);
    final loginRepository = ref.read(loginRepositoryProvider);
    await loginRepository.logout();
    await _clearUserDependentState();
    state = const AsyncData(false);
  }
}
