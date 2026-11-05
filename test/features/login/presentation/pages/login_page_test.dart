import 'dart:async';

import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/widgets/delayed_loader.dart';
import 'package:edubadges/features/login/data/datasources/auto_login_suppression_storage.dart';
import 'package:edubadges/features/login/domain/web_auto_login.dart';
import 'package:edubadges/features/login/presentation/pages/login_page.dart';
import 'package:edubadges/features/login/presentation/providers/auto_login_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/heading_levels.dart';

class _FakeSuppressionStorage implements AutoLoginSuppressionStorage {
  _FakeSuppressionStorage(this.stored);

  AutoLoginSuppression? stored;

  @override
  AutoLoginSuppression? read() => stored;

  @override
  void write(AutoLoginSuppression reason) => stored = reason;

  @override
  void clear() => stored = null;
}

/// Auth whose login either never returns (the browser left for eduID) or
/// fails before the redirect.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({required this.loggedIn, required this.loginFails});

  /// Null keeps authentication resolving forever.
  final bool? loggedIn;
  final bool loginFails;
  int loginCalls = 0;
  bool? lastReplaceHistory;

  @override
  Future<bool> build() {
    final bool? value = loggedIn;
    return value == null ? Completer<bool>().future : Future.value(value);
  }

  @override
  Future<bool> login({bool replaceHistory = false}) async {
    loginCalls++;
    lastReplaceHistory = replaceHistory;
    state = const AsyncLoading();
    if (loginFails) {
      state = AsyncError(Exception('login failed'), StackTrace.empty);
      return false;
    }
    await Completer<void>().future;
    return true;
  }
}

final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

void main() {
  late _FakeAuthNotifier auth;
  late _FakeSuppressionStorage storage;

  Future<void> pumpLoginPage(
    WidgetTester tester, {
    required bool web,
    bool? loggedIn = false,
    bool loginFails = false,
    AutoLoginSuppression? suppression,
  }) async {
    // Tall enough for the landing page, which does not scroll.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    auth = _FakeAuthNotifier(loggedIn: loggedIn, loginFails: loginFails);
    storage = _FakeSuppressionStorage(suppression);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => auth),
          autoLoginSupportedProvider.overrideWithValue(web),
          autoLoginSuppressionStorageProvider.overrideWithValue(storage),
        ],
        child: MaterialApp(
          theme: AppThemes.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LoginPage(),
        ),
      ),
    );
    // Resolve authentication, then run the post-frame auto login, if any.
    await tester.pump();
    await tester.pump();
  }

  final Finder landing = find.text(_l10n.loginCardButton);
  final Finder loader = find.byType(DelayedLoader);
  final Finder error = find.text(_l10n.loginFailedMessage);

  group('web', () {
    testWidgets('a logged-out visitor goes to eduID without the landing page', (
      tester,
    ) async {
      await pumpLoginPage(tester, web: true);

      expect(auth.loginCalls, 1);
      expect(auth.lastReplaceHistory, isTrue);
      expect(loader, findsOneWidget);
      expect(landing, findsNothing);

      await tester.pump(const Duration(seconds: 5));
      expect(auth.loginCalls, 1);
      expect(landing, findsNothing);
    });

    testWidgets('shows only a loader while authentication resolves', (
      tester,
    ) async {
      await pumpLoginPage(tester, web: true, loggedIn: null);

      expect(auth.loginCalls, 0);
      expect(loader, findsOneWidget);
      expect(landing, findsNothing);
    });

    testWidgets('after logout shows the landing page and waits for the user', (
      tester,
    ) async {
      await pumpLoginPage(
        tester,
        web: true,
        suppression: AutoLoginSuppression.loggedOut,
      );

      expect(auth.loginCalls, 0);
      expect(landing, findsOneWidget);
      expect(error, findsNothing);

      await tester.tap(landing);
      await tester.pump();

      expect(auth.loginCalls, 1);
      expect(auth.lastReplaceHistory, isFalse);
      expect(storage.stored, isNull);
    });

    testWidgets('after a failed login shows the error and does not retry', (
      tester,
    ) async {
      await pumpLoginPage(
        tester,
        web: true,
        suppression: AutoLoginSuppression.loginFailed,
      );

      expect(auth.loginCalls, 0);
      expect(landing, findsOneWidget);
      expect(error, findsOneWidget);

      await tester.tap(landing);
      await tester.pump();

      expect(auth.loginCalls, 1);
      expect(storage.stored, isNull);
    });

    testWidgets('a login that fails before the redirect does not loop', (
      tester,
    ) async {
      await pumpLoginPage(tester, web: true, loginFails: true);
      await tester.pump();

      expect(auth.loginCalls, 1);
      expect(landing, findsOneWidget);
      expect(error, findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      expect(auth.loginCalls, 1);
    });
  });

  group('mobile', () {
    testWidgets('keeps the landing page and never logs in by itself', (
      tester,
    ) async {
      await pumpLoginPage(tester, web: false);

      expect(auth.loginCalls, 0);
      expect(landing, findsOneWidget);
      expect(error, findsNothing);

      await tester.tap(landing);
      await tester.pump();

      expect(auth.loginCalls, 1);
    });

    testWidgets('ignores a web suppression', (tester) async {
      await pumpLoginPage(
        tester,
        web: false,
        suppression: AutoLoginSuppression.loginFailed,
      );

      expect(landing, findsOneWidget);
      expect(error, findsNothing);
    });
  });

  group('accessibility', () {
    testWidgets('names the logo for screen readers', (tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpLoginPage(tester, web: false);

      expect(find.bySemanticsLabel(_l10n.appName), findsOneWidget);
      // Named as text: an image node would sit inside the app bar.
      final SemanticsNode logo = tester.getSemantics(
        find.bySemanticsLabel(_l10n.appName),
      );
      expect(logo, isSemantics(isHeader: false, label: _l10n.appName));
      expect(logo.childrenCount, 0);
      semantics.dispose();
    });

    testWidgets('the login title is the only heading, at the page level', (
      tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpLoginPage(tester, web: false);

      expect(headingLevels(tester), {_l10n.loginTitle: 1});
      semantics.dispose();
    });

    testWidgets('reads the card text as text, not as a group label', (
      tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpLoginPage(tester, web: false);

      // As the card's own label, the text wrapped the login button and
      // reached the browser only as an aria-label of that group.
      final SemanticsNode text = tester.getSemantics(
        find.text(_l10n.loginCardText),
      );
      expect(text.getSemanticsData().label, _l10n.loginCardText);
      expect(text.childrenCount, 0);
      semantics.dispose();
    });
  });
}
