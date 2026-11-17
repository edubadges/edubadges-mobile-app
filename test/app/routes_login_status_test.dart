import 'dart:async';

import 'package:edubadges/app/routes.dart';
import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/features/login/data/datasources/login_remote_datasource.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';
import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _SignedIn extends AuthNotifier {
  @override
  Future<bool> build() async => true;
}

class _SignedOut extends AuthNotifier {
  @override
  Future<bool> build() async => false;
}

/// `/login` that answers only when the test completes [response].
class _FakeLoginRemote implements LoginRemoteDataSource {
  final Completer<LoginUserAuthStatus> response =
      Completer<LoginUserAuthStatus>();
  int calls = 0;

  @override
  Future<LoginUserAuthStatus> login() {
    calls++;
    return response.future;
  }
}

/// What `/login` returns for a brand-new eduID account.
final LoginUserAuthStatus _termsRequired = parseUserAuthStatus({
  'email': 'new@example.com',
  'first_name': 'New',
  'last_name': 'User',
  'terms_agreed': false,
  'terms_agreement_set': [
    {
      'agreed': false,
      'agreed_version': 0,
      'terms': {
        'terms_type': 'terms_of_service',
        'terms_urls': [
          {'url': 'https://example.com/terms-en.md', 'language': 'en'},
        ],
      },
    },
  ],
});

void main() {
  late _FakeLoginRemote remote;
  late GoRouter router;
  late ProviderContainer container;
  late List<String> termsLoaded;

  Future<void> pumpApp(WidgetTester tester) async {
    remote = _FakeLoginRemote();
    termsLoaded = <String>[];
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(_SignedIn.new),
        loginRemoteDataSourceProvider.overrideWithValue(remote),
        shouldShowNotificationPermissionPromptProvider.overrideWith(
          (ref) async => false,
        ),
        markdownContentProvider.overrideWith((ref, url) async {
          termsLoaded.add(url);
          return '# Terms';
        }),
      ],
    );
    addTearDown(container.dispose);
    router = container.read(appRouter);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppThemes.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  // SURF-687: a new eduID user was sent to the home screen before the login
  // status had loaded, and never saw the general terms.
  testWidgets('after login waits for the login status, then shows the terms', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(remote.calls, 1);
    expect(router.state.uri.path, RoutePath.login);

    remote.response.complete(_termsRequired);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(router.state.uri.path, RoutePath.generalTerms);
    expect(termsLoaded, ['https://example.com/terms-en.md']);
  });

  test('does not ask for the login status while logged out', () async {
    final remote = _FakeLoginRemote();
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(_SignedOut.new),
        loginRemoteDataSourceProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);
    final LoginUserAuthStatus? status = await container.read(
      loginStatusProvider.future,
    );

    expect(status, isNull);
    expect(remote.calls, 0);
  });
}
