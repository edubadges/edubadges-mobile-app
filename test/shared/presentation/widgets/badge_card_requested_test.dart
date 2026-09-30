import 'package:dartz/dartz.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

BadgeClassModel _badgeClass() {
  return const BadgeClassModel(
    id: 1,
    name: 'Test badge',
    entityId: 'badge-slug',
    badgeClassType: BadgeClassType.regular,
    image: '',
    userMayEnroll: true,
    selfEnrollmentEnabled: true,
  );
}

Future<List<String>> _pumpRequestedCard(
  WidgetTester tester, {
  DateTime? requestedOn,
  Locale locale = const Locale('en'),
  Either<Failure, void> cancelResult = const Right(null),
}) async {
  final List<String> cancelCalls = [];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cancelEnrollmentProvider.overrideWithValue((String badgeClassId) async {
          cancelCalls.add(badgeClassId);
          return cancelResult;
        }),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: BadgeCard(
              instance: null,
              badgeClass: _badgeClass(),
              onTapDisabled: true,
              badgeRequested: true,
              requestedOn: requestedOn,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return cancelCalls;
}

void main() {
  setUpAll(() {
    // BadgeCard builds image URLs from the configured API host.
    if (!EnvironmentConfig.instance.isInitialized) {
      EnvironmentConfig.instance.init(
        apiUrl: 'https://api.example.test',
        openIdUrl: 'https://login.example.test',
        openIdClientId: 'test-client',
        enableAnalytics: false,
        enableCrashlytics: false,
        publicCollectionBaseUrl: 'https://example.test',
        piwikProBaseUrl: 'https://analytics.example.test',
        piwikProSiteId: 'test-site',
      );
    }
  });

  testWidgets('shows the request date and a cancel button', (
    WidgetTester tester,
  ) async {
    await _pumpRequestedCard(tester, requestedOn: DateTime(2026, 7, 23));

    expect(find.text('Requested on 23 Jul, 2026'), findsOneWidget);
    expect(find.text('Cancel request'), findsOneWidget);
    expect(find.text('Request'), findsNothing);
  });

  testWidgets('falls back to the generic status without a request date', (
    WidgetTester tester,
  ) async {
    await _pumpRequestedCard(tester);

    expect(find.text('Edubadge requested'), findsOneWidget);
    expect(find.text('Cancel request'), findsOneWidget);
  });

  testWidgets('uses Dutch labels and date format', (WidgetTester tester) async {
    final DateTime requestedOn = DateTime(2026, 7, 23);
    await _pumpRequestedCard(
      tester,
      requestedOn: requestedOn,
      locale: const Locale('nl'),
    );

    final String date = DateFormat('d MMM, yyyy', 'nl').format(requestedOn);
    expect(find.text('Aangevraagd op $date'), findsOneWidget);
    expect(find.text('Aanvraag intrekken'), findsOneWidget);
  });

  testWidgets('dismissing the confirmation keeps the request', (
    WidgetTester tester,
  ) async {
    final cancelCalls = await _pumpRequestedCard(tester);

    await tester.tap(find.text('Cancel request'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel edubadge request'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel edubadge request'), findsNothing);
    expect(cancelCalls, isEmpty);
  });

  testWidgets('confirming cancels the request and shows a confirmation', (
    WidgetTester tester,
  ) async {
    final cancelCalls = await _pumpRequestedCard(tester);

    await tester.tap(find.text('Cancel request'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(cancelCalls, ['badge-slug']);
    expect(find.text('Request cancelled'), findsOneWidget);
  });

  testWidgets(
    'shows the API error when the request can no longer be cancelled',
    (WidgetTester tester) async {
      final cancelCalls = await _pumpRequestedCard(
        tester,
        cancelResult: const Left(
          ValidationFailure('Cannot withdraw', apiErrorCode: 206),
        ),
      );

      await tester.tap(find.text('Cancel request'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(cancelCalls, ['badge-slug']);
      expect(
        find.text('Accepted requests for edubadges cannot be withdrawn.'),
        findsOneWidget,
      );
      expect(find.text('Request cancelled'), findsNothing);
    },
  );
}
