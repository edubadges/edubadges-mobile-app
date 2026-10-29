import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/pages/account_page.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

Finder _option(String name) {
  return find.widgetWithText(RadioListTile<AppLanguage>, name);
}

/// Pumps the account page in an app whose locale follows the chosen language,
/// the way the real app widget does.
Future<void> _pumpAccountPage(
  WidgetTester tester, {
  Locale deviceLocale = const Locale('en', 'US'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 2000);
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [deviceLocale];
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
  testWidgets('shows both languages in their own language, the current one '
      'checked', (WidgetTester tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpAccountPage(tester);

    expect(find.text('Language'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(RadioGroup<AppLanguage>)).role,
      SemanticsRole.radioGroup,
    );
    expect(
      tester.getSemantics(_option('English')),
      isSemantics(
        label: 'English',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(_option('Nederlands')),
      isSemantics(
        label: 'Nederlands',
        hasCheckedState: true,
        isChecked: false,
        isInMutuallyExclusiveGroup: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('sits between the notification and agreement cards', (
    WidgetTester tester,
  ) async {
    await _pumpAccountPage(tester);

    final double notifications = tester
        .getTopLeft(find.text('Notification settings'))
        .dy;
    final double language = tester.getTopLeft(find.text('Language')).dy;
    final double agreements = tester
        .getTopLeft(find.text('Given agreement(s)'))
        .dy;

    expect(language, greaterThan(notifications));
    expect(language, lessThan(agreements));
  });

  testWidgets('tapping the other language switches the whole page', (
    WidgetTester tester,
  ) async {
    await _pumpAccountPage(tester);
    final State<AccountPage> pageState = tester.state(find.byType(AccountPage));
    expect(find.text('Notification settings'), findsOneWidget);
    expect(find.text('Example University'), findsOneWidget);

    // Anywhere on the row selects it, not just the radio.
    await tester.tapAt(
      tester.getTopLeft(_option('Nederlands')) + const Offset(4, 8),
    );
    await tester.pumpAndSettle();

    expect(find.text('Taal'), findsOneWidget);
    expect(find.text('Notificatie-instellingen'), findsOneWidget);
    expect(find.text('Gegeven akkoordverklaring(en)'), findsOneWidget);
    // Institution names from the API follow the language as well.
    expect(find.text('Universiteit Voorbeeld'), findsOneWidget);
    expect(find.text('Example University'), findsNothing);
    expect(
      tester
          .widget<RadioGroup<AppLanguage>>(find.byType(RadioGroup<AppLanguage>))
          .groupValue,
      AppLanguage.dutch,
    );
    // Same page state: the switch did not remount or navigate.
    expect(tester.state(find.byType(AccountPage)), same(pageState));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AppLanguageNotifier.storageKey), 'nl');
  });

  testWidgets('can be operated with the keyboard', (WidgetTester tester) async {
    await _pumpAccountPage(tester, deviceLocale: const Locale('nl', 'NL'));
    expect(find.text('Taal'), findsOneWidget);

    Focus.of(tester.element(find.text('English'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();

    expect(find.text('Taal'), findsOneWidget);
  });

  testWidgets('section titles are headings of their own', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpAccountPage(tester);

    // Merged into its card, a whole section was the heading, which the web
    // exposes as a page banner.
    for (final String title in <String>['Data', 'Language']) {
      final SemanticsNode node = tester.getSemantics(find.text(title));
      expect(node, isSemantics(isHeader: true, label: title), reason: title);
      expect(node.childrenCount, 0, reason: title);
    }
    semantics.dispose();
  });
}
