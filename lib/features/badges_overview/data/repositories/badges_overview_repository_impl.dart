import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/errors/repository_guard.dart';
import 'package:edubadges/features/badges_overview/data/datasources/badges_overview_datasource.dart';
import 'package:edubadges/features/badges_overview/domain/repositories/badges_overview_repository.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

class BadgesOverviewRepositoryImpl implements BadgesOverviewRepository {
  final BadgesOverviewDataSource badgesOverviewDataSource;

  BadgesOverviewRepositoryImpl(this.badgesOverviewDataSource);

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getBadgeInstances() async {
    return repositoryGuard<List<BadgeInstanceEntity>>(
      () => badgesOverviewDataSource.getBadgeInstances(),
      logMessage: 'Failed to fetch badge instances',
    );
  }

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getDirectAwards() async {
    return repositoryGuard<List<BadgeInstanceEntity>>(
      () => badgesOverviewDataSource.getDirectAwards(),
      logMessage: 'Failed to fetch direct awards',
    );
  }

  @override
  Future<Either<Failure, BadgeInstanceEntity>> getDirectAward(
    String entityId,
  ) async {
    return repositoryGuard<BadgeInstanceEntity>(
      () => badgesOverviewDataSource.getDirectAward(entityId),
      logMessage: 'Failed to fetch direct award',
    );
  }

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getEnrollments() async {
    return repositoryGuard<List<BadgeInstanceEntity>>(
      () => badgesOverviewDataSource.getEnrollments(),
      logMessage: 'Failed to fetch enrollments',
    );
  }

  @override
  Future<Either<Failure, void>> claimBadge(String entityId) async {
    return repositoryGuard<void>(() async {
      await badgesOverviewDataSource.claimBadge(entityId);
      return;
    }, logMessage: 'Failed to claim badge');
  }

  @override
  Future<Either<Failure, void>> declineBadge(String entityId) async {
    return repositoryGuard<void>(() async {
      await badgesOverviewDataSource.declineBadge(entityId);
      return;
    }, logMessage: 'Failed to decline badge');
  }
}
