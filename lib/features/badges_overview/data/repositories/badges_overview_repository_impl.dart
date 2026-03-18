import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badges_overview/data/datasources/badges_overview_datasource.dart';
import 'package:edubadges/features/badges_overview/domain/entities/direct_award_detail_entity.dart';
import 'package:edubadges/features/badges_overview/domain/repositories/badges_overview_repository.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

class BadgesOverviewRepositoryImpl implements BadgesOverviewRepository {
  final BadgesOverviewDataSource badgesOverviewDataSource;

  BadgesOverviewRepositoryImpl(this.badgesOverviewDataSource);

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getBadgeInstances() async {
    try {
      final models = await badgesOverviewDataSource.getBadgeInstances();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getDirectAwards() async {
    try {
      final models = await badgesOverviewDataSource.getDirectAwards();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DirectAwardDetailEntity>> getDirectAwardByEntityId(
    String entityId,
  ) async {
    try {
      final model =
          await badgesOverviewDataSource.getDirectAwardByEntityId(entityId);
      if (model == null) {
        return Left(const ServerFailure('Direct award not found', 404));
      }
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  @override
  Future<Either<Failure, List<BadgeInstanceEntity>>> getEnrollments() async {
    try {
      final models = await badgesOverviewDataSource.getEnrollments();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> claimBadge(String entityId) async {
    try {
      await badgesOverviewDataSource.claimBadge(entityId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  @override
  Future<Either<Failure, void>> declineBadge(String entityId) async {
    try {
      await badgesOverviewDataSource.declineBadge(entityId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }
}
