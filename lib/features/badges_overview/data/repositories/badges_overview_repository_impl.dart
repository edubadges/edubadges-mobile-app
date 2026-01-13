import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badges_overview/data/datasources/badges_overview_datasource.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_entity.dart';
import 'package:edubadges/features/badges_overview/domain/repositories/badges_overview_repository.dart';

class BadgesOverviewRepositoryImpl implements BadgesOverviewRepository {
  final BadgesOverviewDataSource badgesOverviewDataSource;

  BadgesOverviewRepositoryImpl(this.badgesOverviewDataSource);

  @override
  Future<Either<Failure, List<BadgesOverviewEntity>>>
  getBadgesOverviews() async {
    try {
      final models = await badgesOverviewDataSource.getBadgesOverviews();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BadgesOverviewEntity>> getBadgesOverviewById(
    String id,
  ) async {
    try {
      final model = await badgesOverviewDataSource.getBadgesOverviewById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
