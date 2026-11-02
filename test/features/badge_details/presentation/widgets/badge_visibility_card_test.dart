import 'package:dartz/dartz.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badge_details/presentation/widgets/badge_visibility_card.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _linkedinUrl =
    'https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME';

class _FakeBadgeDetailsRepository implements BadgeDetailsRepository {
  _FakeBadgeDetailsRepository(this.instance);

  final BadgeInstanceModel instance;
  final List<String> getBadgeInstanceCalls = [];

  @override
  Future<Either<Failure, BadgeInstanceModel>> getBadgeInstance(
    String entityId,
  ) async {
    getBadgeInstanceCalls.add(entityId);
    return Right(instance);
  }

  @override
  Future<Either<Failure, BadgeClassModel>> getBadgeDetails(String entityId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> enroll(String badgeclassSlug) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> cancelEnrollment(String enrollmentEntityId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateBadgeVisibility(
    String entityId, {
    required bool isPublic,
    required bool includeEvidence,
    required bool includeGradeAchieved,
  }) {
    throw UnimplementedError();
  }
}

BadgeClassModel _badgeClass() {
  return const BadgeClassModel(
    id: 1,
    name: 'Test badge',
    entityId: 'badge-class-1',
    badgeClassType: BadgeClassType.regular,
    image: 'https://example.com/badge.png',
  );
}

BadgeInstanceModel _instance({required bool public, String? linkedinUrl}) {
  return BadgeInstanceModel(
    id: 1,
    createdAt: DateTime.utc(2026, 8, 25),
    entityId: 'instance-1',
    issuedOn: DateTime.utc(2026, 8, 25),
    awardType: 'requested',
    revoked: false,
    acceptance: BadgeAcceptance.accepted,
    public: public,
    badgeclass: _badgeClass(),
    linkedinUrl: linkedinUrl,
  );
}

Future<_FakeBadgeDetailsRepository> _pumpCard(
  WidgetTester tester, {
  required BadgeInstanceModel badge,
}) async {
  final repository = _FakeBadgeDetailsRepository(
    _instance(public: true, linkedinUrl: _linkedinUrl),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [badgeDetailsRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: BadgeVisibilityCard(badge: badge, showCopyLink: badge.public),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return repository;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // The copied link is built from the configured public host.
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

  testWidgets(
    'loads the badge instance details to share a public badge that came '
    'without a linkedin url',
    (WidgetTester tester) async {
      // The badge instance list endpoint omits `linkedin_url`, so badges opened
      // from the catalog or the overview reach the card without one.
      final repository = await _pumpCard(
        tester,
        badge: _instance(public: true),
      );

      expect(repository.getBadgeInstanceCalls, ['instance-1']);
      expect(find.text('Linkedin'), findsOneWidget);
    },
  );

  testWidgets('uses the linkedin url the badge already carries', (
    WidgetTester tester,
  ) async {
    final repository = await _pumpCard(
      tester,
      badge: _instance(public: true, linkedinUrl: _linkedinUrl),
    );

    expect(repository.getBadgeInstanceCalls, isEmpty);
    expect(find.text('Linkedin'), findsOneWidget);
  });

  testWidgets('does not offer sharing options for a private badge', (
    WidgetTester tester,
  ) async {
    final repository = await _pumpCard(tester, badge: _instance(public: false));

    expect(repository.getBadgeInstanceCalls, isEmpty);
    expect(find.text('Linkedin'), findsNothing);
    expect(find.text('Copy link'), findsNothing);
  });

  testWidgets('explains the setting only while the badge is private', (
    WidgetTester tester,
  ) async {
    const String description =
        'With this setting, you determine whether your edubadge is public and '
        'can be viewed by others when you share it.';

    await _pumpCard(tester, badge: _instance(public: false));
    expect(find.text(description), findsOneWidget);

    await _pumpCard(
      tester,
      badge: _instance(public: true, linkedinUrl: _linkedinUrl),
    );
    expect(find.text(description), findsNothing);
  });

  testWidgets('keeps saying the link was copied after the snackbar has gone', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await _pumpCard(
      tester,
      badge: _instance(public: true, linkedinUrl: _linkedinUrl),
    );

    await tester.tap(find.text('Copy link'));
    // One frame for the clipboard write to finish, one for the snackbar.
    await tester.pump();
    await tester.pump();
    expect(
      copiedText,
      'https://example.test/public/assertions/instance-1?lang=en',
    );
    expect(find.text('Edubadge link copied to clipboard'), findsOneWidget);

    // Let the snackbar finish coming in, time out and animate away.
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Edubadge link copied to clipboard'), findsNothing);
    expect(find.text('Copy link'), findsNothing);
    expect(find.text('Link copied'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
