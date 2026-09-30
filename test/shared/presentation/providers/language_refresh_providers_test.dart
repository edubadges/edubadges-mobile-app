import 'dart:async';

import 'package:edubadges/app/routes.dart';
import 'package:edubadges/core/network/network_config.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/storage/storage_providers.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_state.dart';
import 'package:edubadges/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/collections/presentation/state/collections_notifier.dart';
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:edubadges/shared/presentation/providers/language_refresh_providers.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records, in order, which content was refreshed and in which language.
class _RefreshLog {
  final List<String> entries = [];

  void add(Ref ref, String name) {
    entries.add('$name:${ref.read(appLanguageProvider).code}');
  }
}

final _refreshLogProvider = Provider<_RefreshLog>((ref) => _RefreshLog());

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({required this.loggedIn});

  final bool loggedIn;
  int builds = 0;

  @override
  Future<bool> build() async {
    builds++;
    return loggedIn;
  }
}

class _FakeProfileNotifier extends ProfileNotifier {
  @override
  Future<ProfileEntity?> build() async => null;

  @override
  Future<void> refresh({bool silent = true}) async {
    ref.read(_refreshLogProvider).add(ref, 'profile');
  }
}

class _FakeBadgesOverviewNotifier extends BadgesOverviewNotifier {
  /// Completes a refresh; replaced by a test to hold one open.
  Future<void> Function() onRefresh = () async {};

  @override
  Future<BadgesOverviewState> build() async {
    return const BadgesOverviewState(
      claimedBadges: [],
      unclaimedBadges: [],
      requestedBadges: [],
    );
  }

  @override
  Future<void> refresh({bool silent = true}) async {
    ref.read(_refreshLogProvider).add(ref, 'badges');
    await onRefresh();
  }
}

class _FakeCollectionsNotifier extends CollectionsNotifier {
  @override
  Future<List<CollectionsEntity>> build() async => const [];

  @override
  Future<void> refresh({bool silent = true}) async {
    ref.read(_refreshLogProvider).add(ref, 'collections');
  }
}

class _FakeCatalogNotifier extends CatalogNotifier {
  @override
  Future<CatalogState> build() async => const CatalogState();

  @override
  Future<void> refresh({bool silent = true}) async {
    ref.read(_refreshLogProvider).add(ref, 'catalog');
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuthNotifier auth;
  late _FakeBadgesOverviewNotifier badges;

  setUp(() {
    binding.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    SharedPreferences.setMockInitialValues({});
    badges = _FakeBadgesOverviewNotifier();
  });

  tearDown(binding.platformDispatcher.clearLocalesTestValue);

  /// A container set up like the running app: preferences loaded and the
  /// refresher kept alive, as the app widget does.
  Future<ProviderContainer> createContainer({required bool loggedIn}) async {
    auth = _FakeAuthNotifier(loggedIn: loggedIn);
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => auth),
        profileProvider.overrideWith(_FakeProfileNotifier.new),
        badgesOverviewProvider.overrideWith(() => badges),
        collectionsProvider.overrideWith(_FakeCollectionsNotifier.new),
        catalogProvider.overrideWith(_FakeCatalogNotifier.new),
        shouldShowNotificationPermissionPromptProvider.overrideWith(
          (ref) async => false,
        ),
        networkConfigProvider.overrideWithValue(
          NetworkConfig(baseUrl: 'https://api.example.test'),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);
    container.listen(languageContentRefreshProvider, (_, _) {});
    await container.read(authProvider.future);
    return container;
  }

  Future<void> loadAllContent(ProviderContainer container) async {
    await Future.wait([
      container.read(profileProvider.future),
      container.read(badgesOverviewProvider.future),
      container.read(collectionsProvider.future),
      container.read(catalogProvider.future),
    ]);
  }

  Future<void> switchLanguage(
    ProviderContainer container,
    AppLanguage language,
  ) async {
    await container.read(appLanguageProvider.notifier).setLanguage(language);
    await pumpEventQueue();
  }

  List<String> refreshLog(ProviderContainer container) {
    return container.read(_refreshLogProvider).entries;
  }

  test('refreshes loaded content in the new language, collections after '
      'badges', () async {
    final container = await createContainer(loggedIn: true);
    await loadAllContent(container);

    await switchLanguage(container, AppLanguage.dutch);

    final log = refreshLog(container);
    expect(
      log,
      containsAll(<String>[
        'catalog:nl',
        'profile:nl',
        'badges:nl',
        'collections:nl',
      ]),
    );
    expect(log, hasLength(4));
    expect(
      log.indexOf('collections:nl'),
      greaterThan(log.indexOf('badges:nl')),
    );
  });

  test('leaves the session, the router and the API client alone', () async {
    final container = await createContainer(loggedIn: true);
    await loadAllContent(container);
    final AuthNotifier authNotifier = container.read(authProvider.notifier);
    final router = container.read(appRouter);
    final apiClient = container.read(apiClientProvider);

    await switchLanguage(container, AppLanguage.dutch);

    expect(container.read(authProvider.notifier), same(authNotifier));
    expect(auth.builds, 1);
    expect(container.read(authProvider).value, isTrue);
    expect(container.read(appRouter), same(router));
    expect(container.read(apiClientProvider), same(apiClient));
  });

  test('does not load content that was never loaded', () async {
    final container = await createContainer(loggedIn: true);

    await switchLanguage(container, AppLanguage.dutch);

    expect(refreshLog(container), isEmpty);
    expect(container.exists(profileProvider), isFalse);
    expect(container.exists(badgesOverviewProvider), isFalse);
    expect(container.exists(collectionsProvider), isFalse);
    expect(container.exists(catalogProvider), isFalse);
  });

  test('only refreshes public content when logged out', () async {
    final container = await createContainer(loggedIn: false);
    await loadAllContent(container);

    await switchLanguage(container, AppLanguage.dutch);

    expect(refreshLog(container), ['catalog:nl']);
  });

  test('drops the terms URL cached for the previous language', () async {
    final container = await createContainer(loggedIn: true);
    container
        .read(generalTermsMarkdownUrlCacheProvider.notifier)
        .setUrl('https://example.test/terms-en.md');

    await switchLanguage(container, AppLanguage.dutch);

    expect(container.read(generalTermsMarkdownUrlCacheProvider), isNull);
  });

  test('switches made during a refresh end in one more pass for the last '
      'language', () async {
    final container = await createContainer(loggedIn: true);
    await container.read(badgesOverviewProvider.future);
    final firstPass = Completer<void>();
    badges.onRefresh = () => firstPass.future;

    await switchLanguage(container, AppLanguage.dutch);
    badges.onRefresh = () async {};
    await switchLanguage(container, AppLanguage.english);
    await switchLanguage(container, AppLanguage.dutch);
    firstPass.complete();
    await pumpEventQueue();

    expect(refreshLog(container), ['badges:nl', 'badges:nl']);
  });
}
