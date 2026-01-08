import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_entity.dart';

abstract class CatalogRepository {
  Future<Either<Failure, List<CatalogEntity>>> getCatalogs();
  Future<Either<Failure, CatalogEntity>> getCatalogById(String id);
}
