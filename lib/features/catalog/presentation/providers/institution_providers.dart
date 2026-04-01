import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/catalog/data/datasources/institution_datasource.dart';
import 'package:edubadges/features/catalog/data/repositories/institution_repository_impl.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_institution.dart';
import 'package:edubadges/features/catalog/domain/repositories/institution_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogInstitutionDataSourceProvider = Provider<CatalogInstitutionDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return CatalogInstitutionDataSourceImpl(client);
});

final catalogInstitutionRepositoryProvider = Provider<CatalogInstitutionRepository>((ref) {
  final datasource = ref.read(catalogInstitutionDataSourceProvider);
  return CatalogInstitutionRepositoryImpl(datasource);
});

final catalogInstitutionsProvider = FutureProvider.autoDispose<List<CatalogInstitution>>((ref) async {
  final repository = ref.read(catalogInstitutionRepositoryProvider);
  final result = await repository.getCatalogInstitutions();
  return result.fold(
    (failure) => throw failure,
    (institutions) => institutions,
  );
});
