import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:edubadges/features/catalog/domain/enums/catalog_institution_type.dart';
import 'package:equatable/equatable.dart';

/// A failure that happened while catalog data was already loaded.
typedef CatalogFailure = ({Object error, StackTrace stackTrace});

class CatalogState extends Equatable {
  final List<CatalogBadge> badges;
  final List<CatalogBadge> catalogBadges; // Original catalog for restoring
  final bool isSearching;
  final String searchTerm;
  final CatalogInstitutionType? selectedInstitutionType;
  final String? selectedInstitutionId;
  final bool hasMore;
  final int currentPage;
  final int totalCount;
  final int catalogPage; // Track catalog pagination separately
  final bool catalogHasMore;
  final CatalogFailure? failure;

  const CatalogState({
    this.badges = const [],
    this.catalogBadges = const [],
    this.isSearching = false,
    this.searchTerm = '',
    this.selectedInstitutionType,
    this.selectedInstitutionId,
    this.hasMore = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.catalogPage = 1,
    this.catalogHasMore = false,
    this.failure,
  });

  /// Unlike the other fields, [failure] is never carried over: any new state
  /// is either a successful update or carries its own failure.
  CatalogState copyWith({
    List<CatalogBadge>? badges,
    List<CatalogBadge>? catalogBadges,
    bool? isSearching,
    String? searchTerm,
    CatalogInstitutionType? selectedInstitutionType,
    bool clearInstitutionType = false,
    String? selectedInstitutionId,
    bool clearInstitutionId = false,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    int? catalogPage,
    bool? catalogHasMore,
    CatalogFailure? failure,
  }) {
    return CatalogState(
      badges: badges ?? this.badges,
      catalogBadges: catalogBadges ?? this.catalogBadges,
      isSearching: isSearching ?? this.isSearching,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedInstitutionType: clearInstitutionType ? null : (selectedInstitutionType ?? this.selectedInstitutionType),
      selectedInstitutionId: clearInstitutionId ? null : (selectedInstitutionId ?? this.selectedInstitutionId),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      catalogPage: catalogPage ?? this.catalogPage,
      catalogHasMore: catalogHasMore ?? this.catalogHasMore,
      failure: failure,
    );
  }

  List<CatalogBadge> get displayBadges => badges;

  @override
  List<Object?> get props => [badges, catalogBadges, isSearching, searchTerm, selectedInstitutionType, selectedInstitutionId, hasMore, currentPage, totalCount, catalogPage, catalogHasMore, failure];
}
