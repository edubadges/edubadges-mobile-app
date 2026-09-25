import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBadgeDetailsRepository implements BadgeDetailsRepository {
  _FakeBadgeDetailsRepository({this.cancelFailure});

  final Failure? cancelFailure;
  final List<String> cancelCalls = [];

  @override
  Future<Either<Failure, BadgeClassModel>> getBadgeDetails(String entityId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, BadgeInstanceModel>> getBadgeInstance(
    String entityId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> enroll(String badgeclassSlug) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> cancelEnrollment(
    String enrollmentEntityId,
  ) async {
    cancelCalls.add(enrollmentEntityId);
    if (cancelFailure != null) {
      return Left(cancelFailure!);
    }
    return const Right(null);
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

class _FakeBadgesOverviewNotifier extends BadgesOverviewNotifier {
  _FakeBadgesOverviewNotifier({
    this.requestedBadges = const [],
    this.onRefresh,
  });

  final List<BadgeInstanceEntity> requestedBadges;
  final void Function()? onRefresh;

  @override
  Future<BadgesOverviewState> build() async {
    return BadgesOverviewState(
      claimedBadges: const [],
      unclaimedBadges: const [],
      requestedBadges: requestedBadges,
    );
  }

  @override
  Future<void> refresh({bool silent = true}) async {
    onRefresh?.call();
  }
}

BadgeClassModel _badgeClass({String entityId = 'badge-slug'}) {
  return BadgeClassModel(
    id: 1,
    name: 'Test badge',
    entityId: entityId,
    badgeClassType: BadgeClassType.regular,
    image: 'https://example.com/badge.png',
    userMayEnroll: true,
    selfEnrollmentEnabled: true,
  );
}

BadgeInstanceEntity _requestedEnrollment({
  String enrollmentId = 'enrollment-1',
  String badgeClassId = 'badge-slug',
}) {
  return BadgeInstanceEntity(
    id: 1,
    createdAt: DateTime.utc(2026, 1, 1),
    entityId: enrollmentId,
    awardType: 'requested',
    revoked: false,
    acceptance: BadgeAcceptance.unaccepted,
    public: false,
    badgeclass: _badgeClass(entityId: badgeClassId),
  );
}

void main() {
  group('cancelEnrollmentProvider', () {
    test('DELETEs enrollment entity id and refreshes overview', () async {
      final repository = _FakeBadgeDetailsRepository();
      var refreshCount = 0;
      final container = ProviderContainer(
        overrides: [
          badgeDetailsRepositoryProvider.overrideWithValue(repository),
          badgesOverviewProvider.overrideWith(
            () => _FakeBadgesOverviewNotifier(
              requestedBadges: [_requestedEnrollment()],
              onRefresh: () => refreshCount += 1,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(cancelEnrollmentProvider)(
        'badge-slug',
      );

      expect(result, const Right<Failure, void>(null));
      expect(repository.cancelCalls, ['enrollment-1']);
      expect(refreshCount, 1);
    });

    test('does not DELETE when enrollment is missing', () async {
      final repository = _FakeBadgeDetailsRepository();
      var refreshCount = 0;
      final container = ProviderContainer(
        overrides: [
          badgeDetailsRepositoryProvider.overrideWithValue(repository),
          badgesOverviewProvider.overrideWith(
            () =>
                _FakeBadgesOverviewNotifier(onRefresh: () => refreshCount += 1),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(cancelEnrollmentProvider)(
        'badge-slug',
      );

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
      expect(repository.cancelCalls, isEmpty);
      expect(refreshCount, 0);
    });

    test('surfaces api error 206 without refreshing', () async {
      const failure = ValidationFailure(
        'Accepted requests cannot be withdrawn',
        apiErrorCode: 206,
      );
      final repository = _FakeBadgeDetailsRepository(cancelFailure: failure);
      var refreshCount = 0;
      final container = ProviderContainer(
        overrides: [
          badgeDetailsRepositoryProvider.overrideWithValue(repository),
          badgesOverviewProvider.overrideWith(
            () => _FakeBadgesOverviewNotifier(
              requestedBadges: [_requestedEnrollment()],
              onRefresh: () => refreshCount += 1,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(cancelEnrollmentProvider)(
        'badge-slug',
      );

      expect(result, const Left<Failure, void>(failure));
      expect(repository.cancelCalls, ['enrollment-1']);
      expect(refreshCount, 0);
    });

    test('surfaces api error 207 without refreshing', () async {
      const failure = ValidationFailure(
        'Users can only withdraw their own requests',
        apiErrorCode: 207,
      );
      final repository = _FakeBadgeDetailsRepository(cancelFailure: failure);
      final container = ProviderContainer(
        overrides: [
          badgeDetailsRepositoryProvider.overrideWithValue(repository),
          badgesOverviewProvider.overrideWith(
            () => _FakeBadgesOverviewNotifier(
              requestedBadges: [_requestedEnrollment()],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(cancelEnrollmentProvider)(
        'badge-slug',
      );

      expect(result, const Left<Failure, void>(failure));
      expect(repository.cancelCalls, ['enrollment-1']);
    });
  });
}
