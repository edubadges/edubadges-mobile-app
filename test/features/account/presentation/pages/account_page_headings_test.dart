import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/pages/account_page.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/heading_levels.dart';

final ProfileEntity _profile = ProfileEntity(
  firstName: 'Petra',
  lastName: 'Penttilä',
  email: 'student@example.test',
  entityId: 'eduid-1',
  marketingOptIn: false,
  isSuperuser: false,
  termsAgreed: true,
  dateJoined: DateTime.utc(2021, 4, 20),
  termsagreementSet: [
    TermsAgreementEntity(
      entityId: 'agreement-1',
      agreed: true,
      agreedVersion: 1,
      agreedAt: DateTime.utc(2025, 11, 15),
      terms: const TermsEntity(
        entityId: 'terms-1',
        termsType: 'formal_badge',
        institution: InstitutionEntity(
          nameDutch: 'Universiteit Voorbeeld',
          nameEnglish: 'Example University',
          imageDutch: '',
          imageEnglish: '',
          identifier: 'example.edu',
          alternativeIdentifier: '',
          legalBasisFormal: '',
          legalBasisInformal: '',
        ),
        termsUrls: [],
      ),
    ),
  ],
);

class _FakeProfileNotifier extends ProfileNotifier {
  @override
  Future<ProfileEntity?> build() async => _profile;
}

class _FakeNotificationEnabledNotifier extends NotificationEnabledNotifier {
  @override
  Future<bool> build() async => false;
}

Future<void> _pumpAccountPage(WidgetTester tester, {required Size size}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [const Locale('en', 'US')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  SharedPreferences.setMockInitialValues({});

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileProvider.overrideWith(_FakeProfileNotifier.new),
        notificationEnabledProvider.overrideWith(
          _FakeNotificationEnabledNotifier.new,
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          theme: AppThemes.lightTheme,
          locale: ref.watch(appLanguageProvider).locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AccountPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final (String layout, Size size) in [
    ('phone', const Size(390, 2000)),
    ('desktop', const Size(1400, 1200)),
  ]) {
    testWidgets('the headings follow the visual hierarchy on a $layout', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await _pumpAccountPage(tester, size: size);

      expect(headingLevels(tester), {
        'Account': 1,
        'Data': 2,
        'Notification settings': 2,
        'Language': 2,
        'Given agreement(s)': 2,
        'Example University': 3,
        'Delete your edubadges account': 2,
      });
      semantics.dispose();
    });
  }
}
