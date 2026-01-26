import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

abstract class BadgeDetailsRepository {
  Future<Either<Failure, BadgeInstanceEntity>> getBadgeDetails(String entityId);
}
