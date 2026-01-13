import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/collections/data/datasources/collections_datasource.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/domain/repositories/collections_repository.dart';

class CollectionsRepositoryImpl implements CollectionsRepository {
  final CollectionsDataSource collectionsDataSource;

  CollectionsRepositoryImpl(this.collectionsDataSource);

  @override
  Future<Either<Failure, List<CollectionsEntity>>> getCollectionss() async {
    try {
      final models = await collectionsDataSource.getCollectionss();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CollectionsEntity>> getCollectionsById(
    String id,
  ) async {
    try {
      final model = await collectionsDataSource.getCollectionsById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
