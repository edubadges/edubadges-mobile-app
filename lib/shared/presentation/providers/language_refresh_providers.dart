import 'dart:async';

import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:edubadges/features/catalog/presentation/providers/institution_providers.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Refetches backend content that is already loaded whenever the app language
/// changes, so it is shown in the new language.
///
/// Requests pick up the new language from the Dio headers (see `dioProvider`),
/// so nothing network- or auth-related is rebuilt: the session, the router and
/// the navigation stack stay as they are. Kept alive by the app widget.
final languageContentRefreshProvider = Provider<LanguageContentRefresher>((
  ref,
) {
  final refresher = LanguageContentRefresher(ref);
  ref.listen<AppLanguage>(appLanguageProvider, (previous, next) {
    if (previous != null && previous != next) {
      unawaited(refresher.refresh());
    }
  });
  return refresher;
});

class LanguageContentRefresher {
  LanguageContentRefresher(this._ref);

  final Ref _ref;

  bool _isRefreshing = false;
  bool _refreshAgain = false;

  /// Refreshes everything loaded. A call made while a refresh is running is
  /// folded into one more pass afterwards, so the last language always wins.
  Future<void> refresh() async {
    if (_isRefreshing) {
      _refreshAgain = true;
      return;
    }
    _isRefreshing = true;
    try {
      do {
        _refreshAgain = false;
        await _refreshLoadedContent();
      } while (_refreshAgain);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _refreshLoadedContent() async {
    try {
      // The terms URL cached at login is for the previous language.
      clearGeneralTermsMarkdownUrlCache(_ref);

      // Screen-scoped providers: invalidating a mounted one reloads it while
      // its current value stays on screen; the rest are simply dropped.
      _ref.invalidate(badgeDetailsProvider);
      _ref.invalidate(badgeInstanceProvider);
      _ref.invalidate(badgeDetailsModelProvider);
      _ref.invalidate(catalogInstitutionsProvider);

      // Long-lived notifiers refresh silently, so content stays up if a
      // request fails. Ones that were never loaded fetch in the new language
      // when first read, so they are left alone.
      await Future.wait<void>([
        if (_ref.exists(catalogProvider))
          _ref.read(catalogProvider.notifier).refresh(),
        if (_isLoggedIn) ...[
          if (_ref.exists(profileProvider))
            _ref.read(profileProvider.notifier).refresh(),
          _refreshBadgesAndCollections(),
        ],
      ]);
    } catch (error, stackTrace) {
      logger.w(
        'Failed to refresh content after a language change',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool get _isLoggedIn =>
      _ref.exists(authProvider) && (_ref.read(authProvider).value ?? false);

  Future<void> _refreshBadgesAndCollections() async {
    if (_ref.exists(badgesOverviewProvider)) {
      await _ref.read(badgesOverviewProvider.notifier).refresh();
    }
    // Collections are built from the badge list, so they go after it.
    if (_ref.exists(collectionsProvider)) {
      await _ref.read(collectionsProvider.notifier).refresh();
    }
  }
}
