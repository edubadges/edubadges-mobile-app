import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badges_overview/domain/entities/direct_award_detail_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

abstract class BadgesOverviewRepository {
  Future<Either<Failure, List<BadgeInstanceEntity>>> getBadgeInstances();
  Future<Either<Failure, List<BadgeInstanceEntity>>> getDirectAwards();
  Future<Either<Failure, DirectAwardDetailEntity>> getDirectAwardByEntityId(
    String entityId,
  );
  Future<Either<Failure, List<BadgeInstanceEntity>>> getEnrollments();
  Future<Either<Failure, void>> claimBadge(String entityId);
  Future<Either<Failure, void>> declineBadge(String entityId);
}
