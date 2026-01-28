import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/badge_details/data/datasources/badge_details_datasource.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository_impl.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final badgeDetailsDataSourceProvider = Provider<BadgeDetailsDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return BadgeDetailsDataSourceImpl(client);
});

final badgeDetailsRepositoryProvider = Provider<BadgeDetailsRepository>((ref) {
  final dataSource = ref.read(badgeDetailsDataSourceProvider);
  return BadgeDetailsRepositoryImpl(dataSource);
});

final badgeDetailsProvider = FutureProvider.autoDispose
    .family<BadgeInstanceEntity, String>((ref, badgeId) async {
      final repository = ref.read(badgeDetailsRepositoryProvider);
      final result = await repository.getBadgeDetails(badgeId);

      return result.fold((failure) => throw failure, (badge) => badge);
    });

final badgeByIdProvider = Provider.family<BadgeInstanceEntity?, String>((
  ref,
  badgeId,
) {
  final badgesAsync = ref.watch(badgesOverviewProvider);

  return badgesAsync.whenOrNull(
    data: (badges) {
      try {
        return badges.claimedBadges.firstWhere(
          (badge) => badge.entityId == badgeId,
        );
      } catch (e) {
        return null;
      }
    },
  );
});

final badgesListProvider = badgesOverviewProvider;

final updateBadgeVisibilityProvider = Provider<
  Future<bool> Function(String entityId, bool isPublic)
>((ref) {
  return (String entityId, bool isPublic) async {
    final repository = ref.read(badgeDetailsRepositoryProvider);
    final result = await repository.updateBadgeVisibility(entityId, isPublic);
    
    return result.fold(
      (failure) => false,
      (_) {
        ref.invalidate(collectionsProvider);
        ref.invalidate(badgeDetailsProvider(entityId));
        ref.invalidate(badgesOverviewProvider);
        return true;
      },
    );
  };
});
