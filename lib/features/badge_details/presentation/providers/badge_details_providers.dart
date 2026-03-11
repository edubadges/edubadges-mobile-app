import 'package:collection/collection.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/badge_details/data/datasources/badge_details_datasource.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_model.dart';
import 'package:edubadges/features/badge_details/domain/entities/badge_details_params.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository_impl.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
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
    .family<BadgeClassModel, String>((ref, badgeId) async {
      final repository = ref.read(badgeDetailsRepositoryProvider);
      final result = await repository.getBadgeDetails(badgeId);

      return result.fold((failure) => throw failure, (badge) => badge);
    });

final badgeDetailsModelProvider = FutureProvider.autoDispose
    .family<BadgeDetailsModel?, BadgeDetailsParams>((ref, params) async {
      final repository = ref.read(badgeDetailsRepositoryProvider);

      // Watch so this provider recomputes when overview/requested list updates
      final badgesListAsync = ref.watch(badgesListProvider);
      final bool badgeRequested = badgesListAsync.value
              ?.requestedBadges
              .firstWhereOrNull(
                (element) =>
                    element.badgeclass.entityId == params.badgeClassEntityId ||
                    element.entityId == params.badgeInstanceEntityId,
              ) !=
          null;

      if (params.badgeInstanceEntityId != null) {
        final result = await repository.getBadgeInstance(
          params.badgeInstanceEntityId!,
        );
        return result.fold(
          (failure) => throw failure,
          (badgeInstance) => BadgeDetailsModel(
            badgeInstance: badgeInstance,
            badgeClass: badgeInstance.badgeclass as BadgeClassModel,
            requested: badgeRequested,
          ),
        );
      }

      if (params.badgeClassEntityId != null) {
        final result = await repository.getBadgeDetails(
          params.badgeClassEntityId!,
        );

        final BadgeInstanceEntity? badgeInstance = badgesListAsync.value
            ?.claimedBadges
            .firstWhereOrNull(
              (element) =>
                  element.badgeclass.entityId == params.badgeClassEntityId,
            );

        return result.fold(
          (failure) => throw failure,
          (badgeClass) => BadgeDetailsModel(
            badgeInstance: badgeInstance as BadgeInstanceModel?,
            badgeClass: badgeClass,
            requested: badgeRequested,
          ),
        );
      }

      return null;
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

final enrollBadgeProvider =
    Provider<Future<bool> Function(String badgeclassSlug)>((ref) {
  return (String badgeclassSlug) async {
    final repository = ref.read(badgeDetailsRepositoryProvider);
    final result = await repository.enroll(badgeclassSlug);

    return result.fold((failure) => false, (_) {
      ref.invalidate(badgesOverviewProvider);
      ref.invalidate(badgeDetailsModelProvider);
      ref.invalidate(badgeDetailsProvider(badgeclassSlug));
      return true;
    });
  };
});

final updateBadgeVisibilityProvider =
    Provider<
      Future<bool> Function(
        String entityId,
        bool isPublic,
        bool includeEvidence,
        bool includeGradeAchieved,
      )
    >((ref) {
      return (
        String entityId,
        bool isPublic,
        bool includeEvidence,
        bool includeGradeAchieved,
      ) async {
        final repository = ref.read(badgeDetailsRepositoryProvider);
        final result = await repository.updateBadgeVisibility(
          entityId,
          isPublic,
          includeEvidence,
          includeGradeAchieved,
        );

        return result.fold((failure) => false, (_) {
          ref.invalidate(collectionsProvider);
          ref.invalidate(badgeDetailsProvider(entityId));
          ref.invalidate(badgesOverviewProvider);
          return true;
        });
      };
    });
