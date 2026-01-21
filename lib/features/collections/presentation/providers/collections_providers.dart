import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/data/models/collections_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collectionsProvider =
    AsyncNotifierProvider<CollectionsNotifier, List<CollectionsModel>>(
      CollectionsNotifier.new,
    );

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
}
