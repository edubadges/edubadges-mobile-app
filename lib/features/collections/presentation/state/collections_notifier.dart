import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/data/models/collections_model.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionsNotifier extends AsyncNotifier<List<CollectionsModel>> {
  @override
  Future<List<CollectionsModel>> build() async {
    final badgeInstances = await ref.read(badgesOverviewProvider.future);

    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get<List<dynamic>>(
      '/badge-collections',
      queryParameters: {'format': 'json'},
    );

    final collectionsJson = response.data ?? [];
    final collections = collectionsJson
        .map((json) => CollectionsModel.fromJson(json as Map<String, dynamic>))
        .toList();

    final badgeMap = {for (var badge in badgeInstances) badge.id: badge};

    return collections.map((collection) {
      final matchedBadges = collection.badgeInstanceIds
          .map((id) => badgeMap[id])
          .whereType<BadgeInstanceModel>()
          .toList();
      return collection.copyWith(badgeInstances: matchedBadges);
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final badgeInstances = await ref.read(badgesOverviewProvider.future);
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get<List<dynamic>>(
        '/badge-collections',
        queryParameters: {'format': 'json'},
      );

      final collectionsJson = response.data ?? [];
      final collections = collectionsJson
          .map(
            (json) => CollectionsModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final badgeMap = {for (var badge in badgeInstances) badge.id: badge};

      final collectionsWithBadges = collections.map((collection) {
        final matchedBadges = collection.badgeInstanceIds
            .map((id) => badgeMap[id])
            .whereType<BadgeInstanceModel>()
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
    List<int> badgeInstanceIds,
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
        if (currentState is AsyncData<List<CollectionsModel>>) {
          final collections = currentState.value;
          final updatedCollections = collections.map((collection) {
            if (collection.entityId == entityId) {
              return collection.copyWith(
                name: name,
                description: description,
                public: public,
                badgeInstanceIds: badgeInstanceIds,
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
}
