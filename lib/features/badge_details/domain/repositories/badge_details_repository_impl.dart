import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/features/badge_details/data/datasources/badge_details_datasource.dart';
import 'package:edubadges/features/badge_details/domain/repositories/badge_details_repository.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

class BadgeDetailsRepositoryImpl implements BadgeDetailsRepository {
  final BadgeDetailsDataSource dataSource;

  BadgeDetailsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, BadgeInstanceModel>> getBadgeDetails(
    String entityId,
  ) async {
    try {
      final badge = await dataSource.getBadgeDetails(entityId);
      return Right(badge);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}