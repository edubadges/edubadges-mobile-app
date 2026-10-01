import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/domain/repositories/collections_repository.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/collections/presentation/state/collections_notifier.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter_riverpod/misc.dart';

BadgeInstanceEntity testBadge(String entityId, {bool public = true}) {
  return BadgeInstanceEntity(
    id: entityId.hashCode,
    createdAt: DateTime.utc(2025, 8, 22),
    entityId: entityId,
    awardType: 'requested',
    revoked: false,
    acceptance: BadgeAcceptance.accepted,
    public: public,
    badgeclass: BadgeClassModel(
      id: entityId.hashCode,
      name: 'Badge $entityId',
      entityId: 'class-$entityId',
      badgeClassType: BadgeClassType.regular,
      image: 'https://example.com/$entityId.png',
    ),
  );
}

CollectionsEntity testCollection({
  String entityId = 'c1',
  String name = 'Testcollectie 2',
  String? description = 'Omschrijving',
  List<BadgeInstanceEntity> badges = const [],
  bool public = false,
}) {
  return CollectionsEntity(
    id: '1',
    entityId: entityId,
    name: name,
    description: description,
    badgeInstanceIds: [for (final badge in badges) badge.entityId],
    badgeInstances: badges,
    public: public,
  );
}

class PatchCall {
  final String entityId;
  final String? name;
  final String? description;
  final bool? public;
  final List<String>? badgeInstanceIds;

  const PatchCall({
    required this.entityId,
    this.name,
    this.description,
    this.public,
    this.badgeInstanceIds,
  });
}

class CreateCall {
  final String name;
  final String? description;
  final bool public;
  final List<String> badgeInstanceIds;

  const CreateCall({
    required this.name,
    this.description,
    required this.public,
    required this.badgeInstanceIds,
  });
}

class FakeCollectionsRepository implements CollectionsRepository {
  final List<PatchCall> patchCalls = [];
  Either<Failure, void> patchResult = const Right(null);
  final List<CreateCall> createCalls = [];
  Failure? createFailure;

  @override
  Future<Either<Failure, void>> patchCollection({
    required String entityId,
    String? name,
    String? description,
    bool? public,
    List<String>? badgeInstanceIds,
  }) async {
    patchCalls.add(
      PatchCall(
        entityId: entityId,
        name: name,
        description: description,
        public: public,
        badgeInstanceIds: badgeInstanceIds,
      ),
    );
    return patchResult;
  }

  @override
  Future<Either<Failure, List<CollectionsEntity>>> getCollections(
    List<BadgeInstanceEntity> badgeInstances,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteCollection(String entityId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateCollection({
    required String entityId,
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, CollectionsEntity>> createCollection({
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  }) async {
    createCalls.add(
      CreateCall(
        name: name,
        description: description,
        public: public,
        badgeInstanceIds: badgeInstanceIds,
      ),
    );
    final Failure? failure = createFailure;
    if (failure != null) {
      return Left(failure);
    }
    return Right(
      testCollection(entityId: 'new', name: name, description: description),
    );
  }
}

class FakeBadgesOverviewNotifier extends BadgesOverviewNotifier {
  final List<BadgeInstanceEntity> claimedBadges;

  FakeBadgesOverviewNotifier(this.claimedBadges);

  @override
  Future<BadgesOverviewState> build() async {
    return BadgesOverviewState(
      claimedBadges: claimedBadges,
      unclaimedBadges: const [],
      requestedBadges: const [],
    );
  }

  @override
  Future<void> refresh({bool silent = true}) async {}
}

/// Seeds the collections instead of loading them, and counts refreshes
/// instead of hitting the API. Everything else is the real notifier.
class TestCollectionsNotifier extends CollectionsNotifier {
  final List<CollectionsEntity> initialCollections;
  int refreshCount = 0;

  TestCollectionsNotifier(this.initialCollections);

  @override
  Future<List<CollectionsEntity>> build() async => initialCollections;

  @override
  Future<void> refresh({bool silent = true}) async {
    refreshCount++;
  }
}

List<Override> collectionsTestOverrides({
  required FakeCollectionsRepository repository,
  required List<CollectionsEntity> collections,
  required List<BadgeInstanceEntity> claimedBadges,
}) {
  return [
    collectionsRepositoryProvider.overrideWithValue(repository),
    badgesOverviewProvider.overrideWith(
      () => FakeBadgesOverviewNotifier(claimedBadges),
    ),
    collectionsProvider.overrideWith(
      () => TestCollectionsNotifier(collections),
    ),
  ];
}
