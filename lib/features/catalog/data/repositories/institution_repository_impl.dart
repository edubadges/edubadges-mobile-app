import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/errors/repository_guard.dart';
import 'package:edubadges/features/catalog/data/datasources/institution_datasource.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_institution.dart';
import 'package:edubadges/features/catalog/domain/repositories/institution_repository.dart';

class CatalogInstitutionRepositoryImpl implements CatalogInstitutionRepository {
  final CatalogInstitutionDataSource catalogInstitutionDataSource;

  CatalogInstitutionRepositoryImpl(this.catalogInstitutionDataSource);

  @override
  Future<Either<Failure, List<CatalogInstitution>>> getCatalogInstitutions() async {
    return repositoryGuard(
      () => catalogInstitutionDataSource.getCatalogInstitutions(),
      logMessage: 'Failed to fetch catalog institutions',
    );
  }
}
