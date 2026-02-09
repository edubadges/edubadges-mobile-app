import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/catalog/data/datasources/catalog_datasource.dart';
import 'package:edubadges/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_state.dart';
import 'package:edubadges/features/catalog/domain/enums/catalog_institution_type.dart';
import 'package:edubadges/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogDataSourceProvider = Provider<CatalogDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return CatalogDataSourceImpl(client);
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final datasource = ref.read(catalogDataSourceProvider);
  return CatalogRepositoryImpl(datasource);
});

final catalogProvider = AsyncNotifierProvider<CatalogNotifier, CatalogState>(
  CatalogNotifier.new,
);

class CatalogNotifier extends AsyncNotifier<CatalogState> {
  @override
  Future<CatalogState> build() async {
    return _loadCatalogBadges(page: 1);
  }

  Future<CatalogState> _loadCatalogBadges({
    required int page,
    CatalogInstitutionType? institutionType,
    String? institutionId,
  }) async {
    final repository = ref.read(catalogRepositoryProvider);

    final result = await repository.getCatalogBadges(
      page: page,
      institutionType: institutionType,
      institutionId: institutionId,
    );

    return result.fold((failure) => throw failure, (response) {
      return CatalogState(
        badges: response.results,
        catalogBadges: response.results,
        selectedInstitutionType: institutionType,
        selectedInstitutionId: institutionId,
        hasMore: response.hasMore,
        currentPage: page,
        totalCount: response.count,
        catalogPage: page,
        catalogHasMore: response.hasMore,
      );
    });
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    final repository = ref.read(catalogRepositoryProvider);
    final nextPage = currentState.currentPage + 1;

    if (currentState.isSearching) {
      final result = await repository.getCatalogBadges(
        search: currentState.searchTerm,
        institutionType: currentState.selectedInstitutionType,
        institutionId: currentState.selectedInstitutionId,
        page: nextPage,
      );

      result.fold((failure) => throw failure, (response) {
        state = AsyncData(
          currentState.copyWith(
            badges: [...currentState.badges, ...response.results],
            hasMore: response.hasMore,
            currentPage: nextPage,
            totalCount: response.count,
          ),
        );
      });
    } else {
      final result = await repository.getCatalogBadges(
        page: nextPage,
        institutionType: currentState.selectedInstitutionType,
        institutionId: currentState.selectedInstitutionId,
      );

      result.fold((failure) => throw failure, (response) {
        state = AsyncData(
          currentState.copyWith(
            badges: [...currentState.badges, ...response.results],
            catalogBadges: [...currentState.catalogBadges, ...response.results],
            hasMore: response.hasMore,
            currentPage: nextPage,
            catalogPage: nextPage,
            catalogHasMore: response.hasMore,
          ),
        );
      });
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final newState = await _loadCatalogBadges(page: 1);
      state = AsyncData(newState);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> search(String searchTerm) async {
    final currentState = state.value;
    if (currentState == null) return;

    // If search term is empty, restore original catalog
    if (searchTerm.trim().isEmpty) {
      clearSearch();
      return;
    }

    try {
      final repository = ref.read(catalogRepositoryProvider);
      final result = await repository.getCatalogBadges(
        search: searchTerm,
        institutionType: currentState.selectedInstitutionType,
        institutionId: currentState.selectedInstitutionId,
        page: 1,
      );

      result.fold(
        (failure) => throw failure,
        (response) {
          state = AsyncData(
            currentState.copyWith(
              badges: response.results,
              isSearching: true,
              searchTerm: searchTerm,
              hasMore: response.hasMore,
              currentPage: 1,
              totalCount: response.count,
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  /// Filter badges by institution type
  Future<void> filterByInstitutionType(CatalogInstitutionType? institutionType) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final repository = ref.read(catalogRepositoryProvider);
      
      if (currentState.isSearching) {
        // Apply filter to search results
        final result = await repository.getCatalogBadges(
          search: currentState.searchTerm,
          institutionType: institutionType,
          institutionId: currentState.selectedInstitutionId,
          page: 1,
        );

        result.fold(
          (failure) => throw failure,
          (response) {
            state = AsyncData(
              currentState.copyWith(
                badges: response.results,
                selectedInstitutionType: institutionType,
                clearInstitutionType: institutionType == null,
                hasMore: response.hasMore,
                currentPage: 1,
                totalCount: response.count,
              ),
            );
          },
        );
      } else {
        // Apply filter to catalog
        final result = await repository.getCatalogBadges(
          institutionType: institutionType,
          institutionId: currentState.selectedInstitutionId,
          page: 1,
        );

        result.fold(
          (failure) => throw failure,
          (response) {
            state = AsyncData(
              currentState.copyWith(
                badges: response.results,
                catalogBadges: response.results,
                selectedInstitutionType: institutionType,
                clearInstitutionType: institutionType == null,
                hasMore: response.hasMore,
                currentPage: 1,
                catalogPage: 1,
                catalogHasMore: response.hasMore,
                totalCount: response.count,
              ),
            );
          },
        );
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> filterByInstitution(String? institutionId) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final repository = ref.read(catalogRepositoryProvider);
      
      if (currentState.isSearching) {
        final result = await repository.getCatalogBadges(
          search: currentState.searchTerm,
          institutionType: currentState.selectedInstitutionType,
          institutionId: institutionId,
          page: 1,
        );

        result.fold(
          (failure) => throw failure,
          (response) {
            state = AsyncData(
              currentState.copyWith(
                badges: response.results,
                selectedInstitutionId: institutionId,
                clearInstitutionId: institutionId == null,
                hasMore: response.hasMore,
                currentPage: 1,
                totalCount: response.count,
              ),
            );
          },
        );
      } else {
        final result = await repository.getCatalogBadges(
          institutionType: currentState.selectedInstitutionType,
          institutionId: institutionId,
          page: 1,
        );

        result.fold(
          (failure) => throw failure,
          (response) {
            state = AsyncData(
              currentState.copyWith(
                badges: response.results,
                catalogBadges: response.results,
                selectedInstitutionId: institutionId,
                clearInstitutionId: institutionId == null,
                hasMore: response.hasMore,
                currentPage: 1,
                catalogPage: 1,
                catalogHasMore: response.hasMore,
                totalCount: response.count,
              ),
            );
          },
        );
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void clearSearch() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(
        currentState.copyWith(
          badges: currentState.catalogBadges,
          isSearching: false,
          searchTerm: '',
          hasMore: currentState.catalogHasMore,
          currentPage: currentState.catalogPage,
        ),
      );
    }
  }
}
