import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_entity.dart';

abstract class BadgesOverviewRepository {
  Future<Either<Failure, List<BadgesOverviewEntity>>> getBadgesOverviews();
  Future<Either<Failure, BadgesOverviewEntity>> getBadgesOverviewById(
    String id,
  );
}
