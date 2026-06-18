import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_institution.dart';

abstract class CatalogInstitutionRepository {
  Future<Either<Failure, List<CatalogInstitution>>> getCatalogInstitutions();
}
