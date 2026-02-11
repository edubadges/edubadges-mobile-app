import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badges_response.dart';
import 'package:edubadges/features/catalog/domain/enums/catalog_institution_type.dart';

abstract class CatalogRepository {
  Future<Either<Failure, CatalogBadgesResponse>> getCatalogBadges({
    String? search,
    CatalogInstitutionType? institutionType,
    String? institutionId,
    int page = 1,
  });
}
