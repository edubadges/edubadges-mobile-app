import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/errors/repository_guard.dart';
import 'package:edubadges/features/catalog/data/datasources/catalog_datasource.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badges_response.dart';
import 'package:edubadges/features/catalog/domain/enums/catalog_institution_type.dart';
import 'package:edubadges/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogDataSource catalogDataSource;

  CatalogRepositoryImpl(this.catalogDataSource);

  @override
  Future<Either<Failure, CatalogBadgesResponse>> getCatalogBadges({
    String? search,
    CatalogInstitutionType? institutionType,
    String? institutionId,
    int page = 1,
  }) async {
    return repositoryGuard(
      () => catalogDataSource.getCatalogBadges(
        search: search,
        institutionType: institutionType,
        institutionId: institutionId,
        page: page,
      ),
      logMessage: 'Failed to fetch catalog badges',
    );
  }
}
