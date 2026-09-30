import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

abstract class BadgeDetailsRepository {
  Future<Either<Failure, BadgeClassModel>> getBadgeDetails(String entityId);
  Future<Either<Failure, BadgeInstanceModel>> getBadgeInstance(String entityId);
  Future<Either<Failure, void>> enroll(String badgeclassSlug);
  Future<Either<Failure, void>> cancelEnrollment(String enrollmentEntityId);
  Future<Either<Failure, void>> updateBadgeVisibility(
    String entityId, {
    required bool isPublic,
    required bool includeEvidence,
    required bool includeGradeAchieved,
  });
}
