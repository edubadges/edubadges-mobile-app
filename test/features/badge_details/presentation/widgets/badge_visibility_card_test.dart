import 'package:dartz/dartz.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
