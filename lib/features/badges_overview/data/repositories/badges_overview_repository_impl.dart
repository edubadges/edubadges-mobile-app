import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badges_overview/data/datasources/badges_overview_datasource.dart';
import 'package:edubadges/features/badges_overview/domain/repositories/badges_overview_repository.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

class BadgesOverviewRepositoryImpl implements BadgesOverviewRepository {
  final BadgesOverviewDataSource badgesOverviewDataSource;

  BadgesOverviewRepositoryImpl(this.badgesOverviewDataSource);

  @override
  Future<Either<Failure, List<BadgeInstanceModel>>> getBadgeInstances() async {
    try {
      final models = await badgesOverviewDataSource.getBadgeInstances();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
