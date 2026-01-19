import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

abstract class BadgesOverviewRepository {
  Future<Either<Failure, List<BadgeInstanceModel>>> getBadgeInstances();
}
