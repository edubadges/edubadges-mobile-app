import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/catalog/data/datasources/catalog_datasource.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_entity.dart';
import 'package:edubadges/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogDataSource catalogDataSource;

  CatalogRepositoryImpl(this.catalogDataSource);

  @override
  Future<Either<Failure, List<CatalogEntity>>> getCatalogs() async {
    try {
      final models = await catalogDataSource.getCatalogs();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CatalogEntity>> getCatalogById(String id) async {
    try {
      final model = await catalogDataSource.getCatalogById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
