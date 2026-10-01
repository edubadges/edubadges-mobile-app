import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/login/presentation/widgets/login_status_message.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Logged-out auth whose login fails with [loginFailure], the way
/// [AuthNotifier.login] reports a failure.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this.loginFailure);

  final Failure? loginFailure;

  @override
  Future<bool> build() async => false;

  @override
  Future<bool> login({bool replaceHistory = false}) async {
    state = AsyncError(loginFailure!, StackTrace.empty);
    return false;
  }
}

class _ShownNotice extends SessionExpiredNoticeNotifier {
  @override
  bool build() => true;
}

final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

Future<void> _pump(
  WidgetTester tester, {
  Failure? loginFailure,
  bool sessionExpired = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith(() => _FakeAuthNotifier(loginFailure)),
        if (sessionExpired)
          sessionExpiredNoticeProvider.overrideWith(_ShownNotice.new),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LoginStatusMessage()),
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (loginFailure != null) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LoginStatusMessage)),
    );
    await container.read(authProvider.notifier).login();
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('explains that SurfConext could not be reached', (tester) async {
    await _pump(
      tester,
      loginFailure: const NetworkFailure('SurfConext could not be reached'),
    );

    expect(find.text(_l10n.loginConnectionError), findsOneWidget);
    expect(find.text(_l10n.sessionExpiredMessage), findsNothing);
  });

  testWidgets('explains that the session expired', (tester) async {
    await _pump(tester, sessionExpired: true);

    expect(find.text(_l10n.sessionExpiredMessage), findsOneWidget);
    expect(find.text(_l10n.loginConnectionError), findsNothing);
  });

  testWidgets('stays empty after another failure, e.g. a cancelled login', (
    tester,
  ) async {
    await _pump(
      tester,
      loginFailure: const ServerFailure('An unexpected error occurred', 500),
    );

    expect(find.byType(Text), findsNothing);
  });

  testWidgets('stays empty on a normal visit', (tester) async {
    await _pump(tester);

    expect(find.byType(Text), findsNothing);
  });
}
