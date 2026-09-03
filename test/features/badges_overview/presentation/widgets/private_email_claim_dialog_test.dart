import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/domain/repositories/badges_overview_repository.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_page.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBadgesOverviewRepository implements BadgesOverviewRepository {
  _FakeBadgesOverviewRepository({this.directAwardFailure});

  final Failure? directAwardFailure;
  int claimCalls = 0;

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getBadgeInstances() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getDirectAwards() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, BadgeInstanceEntity>> getDirectAward(
    String entityId,
  ) async {
    return Left(directAwardFailure ?? const ServerFailure('unavailable', 500));
  }

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getEnrollments() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> claimBadge(String entityId) async {
    claimCalls += 1;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> declineBadge(String entityId) async {
    return const Right(null);
  }
}

class _FakeBadgeDetailsRepository implements BadgeDetailsRepository {
  _FakeBadgeDetailsRepository(this.badge);

  final BadgeClassModel badge;

  @override
  Future<Either<Failure, BadgeClassModel>> getBadgeDetails(
    String entityId,
  ) async {
    return Right(badge);
  }

  @override
  Future<Either<Failure, BadgeInstanceModel>> getBadgeInstance(
    String entityId,
  ) async {
    return const Left(ServerFailure('unused', 500));
  }

  @override
  Future<Either<Failure, void>> enroll(String badgeclassSlug) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateBadgeVisibility(
    String entityId, {
    required bool isPublic,
    required bool includeEvidence,
    required bool includeGradeAchieved,
  }) async {
    return const Left(ServerFailure('unused', 500));
  }
}

class _FakeBadgesOverviewNotifier extends BadgesOverviewNotifier {
  _FakeBadgesOverviewNotifier(this.stateValue);

  final BadgesOverviewState stateValue;

  @override
  Future<BadgesOverviewState> build() async => stateValue;

  @override
  Future<void> refresh({bool silent = true}) async {}
}

class _FakeProfileNotifier extends ProfileNotifier {
  @override
  Future<ProfileEntity?> build() async {
    return ProfileEntity(
      firstName: 'Henk',
      lastName: 'de Vries',
      email: 'henk@example.com',
      entityId: 'profile-1',
      marketingOptIn: false,
      isSuperuser: false,
      termsAgreed: true,
      termsagreementSet: const [],
      dateJoined: DateTime.utc(2026, 1, 1),
    );
  }
}

BadgeClassModel _badgeClass() {
  return const BadgeClassModel(
    id: 1,
    name: 'Test badge',
    entityId: 'badge-slug',
    badgeClassType: BadgeClassType.regular,
    image: 'https://example.com/badge.png',
    userHasAcceptedTerms: true,
    userMayEnroll: true,
    selfEnrollmentEnabled: true,
  );
}

BadgeInstanceEntity _unclaimedAward({required BadgeClassModel badgeClass}) {
  return BadgeInstanceEntity(
    id: 1,
    createdAt: DateTime.utc(2026, 8, 25),
    entityId: 'award-1',
    awardType: 'direct',
    revoked: false,
    acceptance: BadgeAcceptance.unaccepted,
    public: false,
    badgeclass: badgeClass,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('does not claim when getDirectAward returns Left', (
    WidgetTester tester,
  ) async {
    const failure = ServerFailure('direct award unavailable', 500);
    final overviewRepository = _FakeBadgesOverviewRepository(
      directAwardFailure: failure,
    );
    final badgeClass = _badgeClass();
    final award = _unclaimedAward(badgeClass: badgeClass);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          badgesOverviewRepositoryProvider.overrideWithValue(
            overviewRepository,
          ),
          badgesOverviewProvider.overrideWith(
            () => _FakeBadgesOverviewNotifier(
              BadgesOverviewState(
                claimedBadges: const [],
                unclaimedBadges: [award],
                requestedBadges: const [],
              ),
            ),
          ),
          badgeDetailsRepositoryProvider.overrideWithValue(
            _FakeBadgeDetailsRepository(badgeClass),
          ),
          profileProvider.overrideWith(_FakeProfileNotifier.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: BadgeClaimPage(badgeId: '1', remainingCount: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Claim edubadge'));
    await tester.pumpAndSettle();

    expect(overviewRepository.claimCalls, 0);
    expect(find.text('direct award unavailable'), findsOneWidget);
  });
}
