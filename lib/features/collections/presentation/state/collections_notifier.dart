import 'package:dartz/dartz.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/data/models/collections_model.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionsNotifier extends AsyncNotifier<List<CollectionsEntity>> {
  @override
  Future<List<CollectionsEntity>> build() async {
    final badgesState = await ref.read(badgesOverviewProvider.future);
    final badgeInstances = [
      ...badgesState.claimedBadges,
      ...badgesState.unclaimedBadges,
      ...badgesState.requestedBadges,
    ];

    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get<List<dynamic>>('/badge-collections');

    final collectionsJson = response.data ?? [];
    final collections = collectionsJson
        .map((json) => CollectionsModel.fromJson(json as Map<String, dynamic>))
        .toList();

    final badgeMap = {for (var badge in badgeInstances) badge.entityId: badge};

    return collections.map((collection) {
      final matchedBadges = collection.badgeInstanceIds
          .map((id) => badgeMap[id])
          .whereType<BadgeInstanceEntity>()
          .toList();
      return collection.copyWith(badgeInstances: matchedBadges);
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final badgesState = await ref.read(badgesOverviewProvider.future);
      final badgeInstances = [
        ...badgesState.claimedBadges,
        ...badgesState.unclaimedBadges,
        ...badgesState.requestedBadges,
      ];
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get<List<dynamic>>('/badge-collections');

      final collectionsJson = response.data ?? [];
      final collections = collectionsJson
          .map(
            (json) => CollectionsModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final badgeMap = {
        for (var badge in badgeInstances) badge.entityId: badge,
      };

      final collectionsWithBadges = collections.map((collection) {
        final matchedBadges = collection.badgeInstanceIds
            .map((id) => badgeMap[id])
            .whereType<BadgeInstanceEntity>()
            .toList();
        return collection.copyWith(badgeInstances: matchedBadges);
      }).toList();

      state = AsyncData(collectionsWithBadges);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<bool> deleteCollection(String entityId) async {
    final useCase = ref.read(deleteCollectionUseCaseProvider);
    final result = await useCase(entityId: entityId);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        refresh();
        return true;
      },
    );
  }

  Future<bool> updateCollection(
    String entityId,
    String name,
    String? description,
    bool public,
    List<String> badgeInstanceIds,
  ) async {
    final useCase = ref.read(updateCollectionUseCaseProvider);
    final result = await useCase(
      entityId: entityId,
      name: name,
      description: description,
      public: public,
      badgeInstanceIds: badgeInstanceIds,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        final currentState = state;
        if (currentState is AsyncData<List<CollectionsEntity>>) {
          final collections = currentState.value;
          final updatedCollections = collections.map((collection) {
            if (collection.entityId == entityId) {
              return collection.copyWith(
                name: name,
                description: description,
                public: public,
                badgeInstanceIds: badgeInstanceIds
                    .map((e) => e)
                    .toList(),
              );
            }
            return collection;
          }).toList();
          state = AsyncData(updatedCollections);
        } else {
          refresh();
        }
        return true;
      },
    );
  }

  Future<Either<Failure, void>> createCollection({
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  }) async {
    final useCase = ref.read(createCollectionUseCaseProvider);
    final result = await useCase(
      name: name,
      description: description,
      public: public,
      badgeInstanceIds: badgeInstanceIds,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return Left(failure);
      },
      (_) {
        refresh();
        return const Right(null);
      },
    );
  }
}
