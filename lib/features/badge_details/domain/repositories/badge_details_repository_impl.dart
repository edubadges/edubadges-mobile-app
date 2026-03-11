import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/errors/repository_guard.dart';
import 'package:edubadges/features/badge_details/data/datasources/badge_details_datasource.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

class BadgeDetailsRepositoryImpl implements BadgeDetailsRepository {
  final BadgeDetailsDataSource dataSource;

  BadgeDetailsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, BadgeClassModel>> getBadgeDetails(
    String entityId,
  ) async {
    return repositoryGuard<BadgeClassModel>(
      () => dataSource.getBadgeDetails(entityId),
      logMessage: 'Failed to fetch badge details',
    );
  }

  @override
  Future<Either<Failure, BadgeInstanceModel>> getBadgeInstance(
    String entityId,
  ) async {
    return repositoryGuard<BadgeInstanceModel>(
      () => dataSource.getBadgeInstance(entityId),
      logMessage: 'Failed to fetch badge instance',
    );
  }

  @override
  Future<Either<Failure, void>> enroll(String badgeclassSlug) async {
    return await repositoryGuard<void>(
      () async {
        await dataSource.enroll(badgeclassSlug);
        return;
      },
      logMessage: 'Failed to enroll in badge',
    );
  }

  @override
  Future<Either<Failure, void>> enroll(String badgeclassSlug) async {
    try {
      await dataSource.enroll(badgeclassSlug);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateBadgeVisibility(
    String entityId, {
    required bool isPublic,
    required bool includeEvidence,
    required bool includeGradeAchieved,
  }) async {
    return repositoryGuard<void>(
      () async {
        await dataSource.updateBadgeVisibility(
          entityId,
          isPublic: isPublic,
          includeEvidence: includeEvidence,
          includeGradeAchieved: includeGradeAchieved,
        );
        return;
      },
      logMessage: 'Failed to update badge visibility',
    );
  }
}
