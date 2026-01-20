import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/badges_overview/data/datasources/badges_overview_datasource.dart';
import 'package:edubadges/features/badges_overview/data/repositories/badges_overview_repository_impl.dart';
import 'package:edubadges/features/badges_overview/domain/repositories/badges_overview_repository.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final badgesOverviewDataSourceProvider = Provider<BadgesOverviewDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return BadgesOverviewDataSourceImpl(client);
});

final badgesOverviewRepositoryProvider = Provider<BadgesOverviewRepository>((ref) {
  final datasource = ref.read(badgesOverviewDataSourceProvider);
  return BadgesOverviewRepositoryImpl(datasource);
});

final badgesOverviewProvider = AsyncNotifierProvider<BadgesOverviewNotifier, List<BadgeInstanceModel>>(
  BadgesOverviewNotifier.new,
);

class BadgesOverviewNotifier extends AsyncNotifier<List<BadgeInstanceModel>> {
  @override
  Future<List<BadgeInstanceModel>> build() async {
    final repository = ref.read(badgesOverviewRepositoryProvider);
    final result = await repository.getBadgeInstances();
    
    final badges = result.fold(
      (failure) => throw failure,
      (entities) => entities,
    );
    
    return badges;
  }

  /// Refresh the badge instances list
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(badgesOverviewRepositoryProvider);
      final result = await repository.getBadgeInstances();
      
      result.fold(
        (failure) => state = AsyncError(failure, StackTrace.current),
        (entities) => state = AsyncData(entities),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
