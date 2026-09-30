import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBadgeDetailsRepository implements BadgeDetailsRepository {
  _FakeBadgeDetailsRepository({this.badge, this.detailsFailure});

  final BadgeClassModel? badge;
  final Failure? detailsFailure;
  int enrollCalls = 0;

  @override
  Future<Either<Failure, BadgeClassModel>> getBadgeDetails(
    String entityId,
  ) async {
    if (detailsFailure != null) {
      return Left(detailsFailure!);
    }
    return Right(badge!);
  }

  @override
  Future<Either<Failure, BadgeInstanceModel>> getBadgeInstance(
    String entityId,
  ) async {
    return const Left(ServerFailure('unused', 500));
  }

  @override
  Future<Either<Failure, void>> enroll(String badgeclassSlug) async {
    enrollCalls += 1;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> cancelEnrollment(
    String enrollmentEntityId,
  ) async {
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
  @override
  Future<BadgesOverviewState> build() async {
    return const BadgesOverviewState(
      claimedBadges: [],
      unclaimedBadges: [],
      requestedBadges: [],
    );
  }

  @override
  Future<void> refresh({bool silent = true}) async {}
}

BadgeClassModel _badgeClass({required bool userMayEnroll}) {
  return BadgeClassModel(
    id: 1,
    name: 'Test badge',
    entityId: 'badge-slug',
    badgeClassType: BadgeClassType.regular,
    image: 'https://example.com/badge.png',
    userMayEnroll: userMayEnroll,
    selfEnrollmentEnabled: true,
  );
}

void main() {
  group('enrollBadgeProvider', () {
    test('does not POST enroll when userMayEnroll is false', () async {
      final repository = _FakeBadgeDetailsRepository(
        badge: _badgeClass(userMayEnroll: false),
      );
      final container = ProviderContainer(
        overrides: [
          badgeDetailsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final bool enrolled = await container.read(enrollBadgeProvider)(
        'badge-slug',
      );

      expect(enrolled, isFalse);
      expect(repository.enrollCalls, 0);
    });

    test('does not POST enroll when badge details cannot be loaded', () async {
      final repository = _FakeBadgeDetailsRepository(
        detailsFailure: const ServerFailure('unavailable', 500),
      );
      final container = ProviderContainer(
        overrides: [
          badgeDetailsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final bool enrolled = await container.read(enrollBadgeProvider)(
        'badge-slug',
      );

      expect(enrolled, isFalse);
      expect(repository.enrollCalls, 0);
    });

    test('POSTs enroll when userMayEnroll is true', () async {
      final repository = _FakeBadgeDetailsRepository(
        badge: _badgeClass(userMayEnroll: true),
      );
      final container = ProviderContainer(
        overrides: [
          badgeDetailsRepositoryProvider.overrideWithValue(repository),
          badgesOverviewProvider.overrideWith(_FakeBadgesOverviewNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final bool enrolled = await container.read(enrollBadgeProvider)(
        'badge-slug',
      );

      expect(enrolled, isTrue);
      expect(repository.enrollCalls, 1);
    });
  });
}
