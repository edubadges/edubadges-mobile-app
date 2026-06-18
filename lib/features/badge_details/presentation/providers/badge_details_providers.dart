import 'package:collection/collection.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/badge_details/data/datasources/badge_details_datasource.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_model.dart';
import 'package:edubadges/features/badge_details/domain/entities/badge_details_query.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
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
    .family<BadgeDetailsModel?, BadgeDetailsQuery>((ref, query) async {
      final repository = ref.read(badgeDetailsRepositoryProvider);

      final badgesListAsync = ref.watch(badgesListProvider);
      final overview = badgesListAsync.value;

      final bool badgeRequested =
          overview?.requestedBadges.firstWhereOrNull(
            (element) =>
                element.badgeclass.entityId == query.entityId ||
                element.entityId == query.entityId,
          ) !=
          null;

      switch (query.scope) {
        case BadgeDetailsScope.claimed:
          final result = await repository.getBadgeInstance(query.entityId);
          return result.fold(
            (failure) => throw failure,
            (badgeInstance) => BadgeDetailsModel(
              badgeInstance: badgeInstance,
              badgeClass: badgeInstance.badgeclass as BadgeClassModel,
              requested: badgeRequested,
            ),
          );

        case BadgeDetailsScope.enrollment:
        case BadgeDetailsScope.public:
          final result = await repository.getBadgeDetails(query.entityId);

          final BadgeInstanceEntity? badgeInstance = overview?.claimedBadges
              .firstWhereOrNull(
                (element) => element.badgeclass.entityId == query.entityId,
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
    });

final badgeByIdProvider = Provider.autoDispose
    .family<BadgeInstanceEntity?, String>((ref, badgeId) {
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
          ref.read(badgesOverviewProvider.notifier).refresh();
          ref.invalidate(badgeDetailsModelProvider);
          ref.invalidate(badgeDetailsProvider(badgeclassSlug));
          return true;
        });
      };
    });

final updateBadgeVisibilityProvider =
    Provider<
      Future<bool> Function(
        String entityId, {
        required bool isPublic,
        required bool includeEvidence,
        required bool includeGradeAchieved,
      })
    >((ref) {
      return (
        String entityId, {
        required bool isPublic,
        required bool includeEvidence,
        required bool includeGradeAchieved,
      }) async {
        final repository = ref.read(badgeDetailsRepositoryProvider);
        final result = await repository.updateBadgeVisibility(
          entityId,
          isPublic: isPublic,
          includeEvidence: includeEvidence,
          includeGradeAchieved: includeGradeAchieved,
        );

        return await result.fold<Future<bool>>((_) async => false, (_) async {
          try {
            await ref.read(badgesOverviewProvider.notifier).refresh();
            await ref.read(collectionsProvider.notifier).refresh();
            ref.invalidate(badgeDetailsProvider(entityId));
            ref.invalidate(badgeDetailsModelProvider, asReload: true);
            return true;
          } catch (_) {
            return false;
          }
        });
      };
    });
