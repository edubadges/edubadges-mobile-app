import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/data/models/collections_model.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionsNotifier extends AsyncNotifier<List<CollectionsEntity>> {
  @override
  Future<List<CollectionsEntity>> build() async {
    try {
      final badgesState = await ref.read(badgesOverviewProvider.future);

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get<List<dynamic>>('/badge-collections');

      final collectionsJson = response.data ?? [];
      final collections = collectionsJson
          .map((json) => CollectionsModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final badgeMap = _badgeInstancesById(badgesState);

      return collections
          .map((collection) => _withBadgeInstances(collection, badgeMap))
          .toList();
    } catch (error, stackTrace) {
      logger.e(
        'Failed to build collections state',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> refresh({bool silent = true}) async {
    if (!silent) {
      state = const AsyncLoading();
    }
    try {
      final badgesState = await ref.read(badgesOverviewProvider.future);
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get<List<dynamic>>('/badge-collections');

      final collectionsJson = response.data ?? [];
      final collections = collectionsJson
          .map(
            (json) => CollectionsModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final badgeMap = _badgeInstancesById(badgesState);

      final collectionsWithBadges = collections
          .map((collection) => _withBadgeInstances(collection, badgeMap))
          .toList();

      state = AsyncData(collectionsWithBadges);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to refresh collections',
        error: error,
        stackTrace: stackTrace,
      );
      if (!silent || !state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
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

  Future<bool> updateCollection({
    required String entityId,
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  }) async {
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
                badgeInstanceIds: badgeInstanceIds.map((e) => e).toList(),
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

  /// Partial update via PATCH. Only non-null fields are sent.
  ///
  /// On success the cached collection is updated straight away, including the
  /// badge instances resolved from [badgeInstanceIds], so the detail and the
  /// overview show the change without waiting for the network. The list is
  /// then silently refreshed to match the server.
  ///
  /// A failure is only returned: every caller reports it itself, and the
  /// collections that are already loaded stay on screen.
  Future<Either<Failure, void>> patchCollection({
    required String entityId,
    String? name,
    String? description,
    bool? public,
    List<String>? badgeInstanceIds,
  }) async {
    final useCase = ref.read(updateCollectionUseCaseProvider);
    final result = await useCase.patch(
      entityId: entityId,
      name: name,
      description: description,
      public: public,
      badgeInstanceIds: badgeInstanceIds,
    );

    return result.fold((failure) => Left(failure), (_) {
      _applyPatchLocally(
        entityId: entityId,
        name: name,
        description: description,
        public: public,
        badgeInstanceIds: badgeInstanceIds,
      );
      refresh();
      return const Right(null);
    });
  }

  void _applyPatchLocally({
    required String entityId,
    String? name,
    String? description,
    bool? public,
    List<String>? badgeInstanceIds,
  }) {
    final collections = state.value;
    if (collections == null) {
      return;
    }

    Map<String, BadgeInstanceEntity> badgeMap = const {};
    if (badgeInstanceIds != null) {
      // Badges already shown in a collection are a fallback for the (rare)
      // case where the badges overview is not loaded.
      badgeMap = {
        for (final collection in collections)
          for (final badge
              in collection.badgeInstances ?? const <BadgeInstanceEntity>[])
            badge.entityId: badge,
      };
      final badgesState = ref.read(badgesOverviewProvider).value;
      if (badgesState != null) {
        badgeMap.addAll(_badgeInstancesById(badgesState));
      }
    }

    CollectionsEntity patch(CollectionsEntity collection) {
      final updated = collection.copyWith(
        name: name?.trim(),
        description: description,
        public: public,
        badgeInstanceIds: badgeInstanceIds,
      );
      return badgeInstanceIds == null
          ? updated
          : _withBadgeInstances(updated, badgeMap);
    }

    state = AsyncData([
      for (final collection in collections)
        collection.entityId == entityId ? patch(collection) : collection,
    ]);
  }

  static Map<String, BadgeInstanceEntity> _badgeInstancesById(
    BadgesOverviewState badgesState,
  ) {
    return {
      for (final badge in [
        ...badgesState.claimedBadges,
        ...badgesState.unclaimedBadges,
        ...badgesState.requestedBadges,
      ])
        badge.entityId: badge,
    };
  }

  /// Resolves [CollectionsEntity.badgeInstanceIds] against [badgeMap]; ids
  /// without a known badge are left out.
  static CollectionsEntity _withBadgeInstances(
    CollectionsEntity collection,
    Map<String, BadgeInstanceEntity> badgeMap,
  ) {
    final matchedBadges = collection.badgeInstanceIds
        .map((id) => badgeMap[id])
        .whereType<BadgeInstanceEntity>()
        .toList();
    return collection.copyWith(badgeInstances: matchedBadges);
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
