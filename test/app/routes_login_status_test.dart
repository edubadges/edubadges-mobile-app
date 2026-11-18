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

/// `/login` that answers each call only when the test completes it.
class _FakeLoginRemote implements LoginRemoteDataSource {
  final List<Completer<LoginUserAuthStatus>> responses = [];

  int get calls => responses.length;

  @override
  Future<LoginUserAuthStatus> login() {
    final response = Completer<LoginUserAuthStatus>();
    responses.add(response);
    return response.future;
  }
}

/// What `/login` returns for a brand-new eduID account: no agreements yet.
final LoginUserAuthStatus _newAccount = parseUserAuthStatus({
  'id': 248,
  'email': 'new@example.com',
  'first_name': 'New',
  'last_name': 'User',
  'validated_name': null,
  'schac_homes': <String>[],
  'terms_agreed': false,
  'termsagreement_set': <Object>[],
});

/// What `/login` returns when the user has to accept new terms.
final LoginUserAuthStatus _termsRequired = parseUserAuthStatus({
  'email': 'new@example.com',
  'first_name': 'New',
  'last_name': 'User',
  'terms_agreed': false,
  'termsagreement_set': [
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

final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

void main() {
  late _FakeLoginRemote remote;
  late GoRouter router;
  late ProviderContainer container;
  late List<String> termsLoaded;

  Future<void> pumpApp(WidgetTester tester) async {
    // Tall enough to show the whole login page without scrolling.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);
    remote = _FakeLoginRemote();
    termsLoaded = <String>[];
    container = ProviderContainer(
      // Riverpod retries a failed request by itself; the tests decide when
      // `/login` answers instead.
      retry: (_, _) => null,
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

    remote.responses.single.complete(_termsRequired);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(router.state.uri.path, RoutePath.generalTerms);
    expect(termsLoaded, ['https://example.com/terms-en.md']);
  });

  // SURF-687: a brand-new account has no terms agreements, so `/login` names
  // no terms URL. The redirect threw on that and the app hung on a spinner.
  testWidgets('shows a brand-new account the SURF account terms', (
    tester,
  ) async {
    await pumpApp(tester);

    remote.responses.single.complete(_newAccount);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(router.state.uri.path, RoutePath.generalTerms);
    expect(termsLoaded, [
      'https://raw.githubusercontent.com/edubadges/privacy/master/surf/account-terms-en.md',
    ]);
  });

  testWidgets('stays on login with a retry when the status cannot load', (
    tester,
  ) async {
    await pumpApp(tester);

    remote.responses.single.completeError(Exception('network down'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Not on to the home screen without knowing about the terms.
    expect(router.state.uri.path, RoutePath.login);
    expect(find.text(_l10n.loginFailedMessage), findsOneWidget);

    await tester.tap(find.text(_l10n.loginCardButton));
    await tester.pump();
    expect(remote.calls, 2);

    remote.responses.last.complete(_termsRequired);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(router.state.uri.path, RoutePath.generalTerms);
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
