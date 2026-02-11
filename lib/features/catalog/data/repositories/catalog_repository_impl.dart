import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
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
    try {
      final response = await catalogDataSource.getCatalogBadges(
        search: search,
        institutionType: institutionType,
        institutionId: institutionId,
        page: page,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
