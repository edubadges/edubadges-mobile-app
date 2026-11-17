import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/pages/account_page.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ProfileEntity _profile = ProfileEntity(
  firstName: 'Petra',
  lastName: 'Penttilä',
  email: 'student@example.test',
  entityId: 'eduid-1',
  marketingOptIn: false,
  isSuperuser: false,
  termsAgreed: true,
  dateJoined: DateTime.utc(2021, 4, 20),
  termsagreementSet: const [],
);

class _FakeProfileNotifier extends ProfileNotifier {
  @override
  Future<ProfileEntity?> build() async => _profile;
}

class _FakeNotificationEnabledNotifier extends NotificationEnabledNotifier {
  @override
  Future<bool> build() async => false;
}

Future<void> _pumpAccountPage(
  WidgetTester tester, {
  required Future<PackageInfo> Function() packageInfo,
  Locale locale = const Locale('en'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 2400);
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileProvider.overrideWith(_FakeProfileNotifier.new),
        notificationEnabledProvider.overrideWith(
          _FakeNotificationEnabledNotifier.new,
        ),
        packageInfoProvider.overrideWith((ref) => packageInfo()),
      ],
      child: MaterialApp(
        theme: AppThemes.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AccountPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<PackageInfo> _version() async => PackageInfo(
  appName: 'Edubadges',
  packageName: 'nl.surf.edubadges',
  version: '1.0.4',
  buildNumber: '12',
);

void main() {
  testWidgets('shows the installed version and build number', (
    WidgetTester tester,
  ) async {
    await _pumpAccountPage(tester, packageInfo: _version);

    expect(find.text('Version 1.0.4 (12)'), findsOneWidget);
  });

  testWidgets('labels the version in Dutch', (WidgetTester tester) async {
    await _pumpAccountPage(
      tester,
      packageInfo: _version,
      locale: const Locale('nl'),
    );

    expect(find.text('Versie 1.0.4 (12)'), findsOneWidget);
  });

  testWidgets('shows no version line when the version cannot be read', (
    WidgetTester tester,
  ) async {
    await _pumpAccountPage(
      tester,
      packageInfo: () => Future.error(Exception('no platform info')),
    );

    expect(find.textContaining('Version'), findsNothing);
    expect(find.text('Delete my account'), findsOneWidget);
  });
}
