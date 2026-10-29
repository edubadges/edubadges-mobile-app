import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/page_header.dart';
import 'package:edubadges/core/widgets/sidebar_list_layout.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_state.dart';
import 'package:edubadges/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:edubadges/features/catalog/presentation/widgets/catalog_badge_card.dart';
import 'package:edubadges/features/catalog/presentation/widgets/catalog_filters.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/widgets/badge_grid_tile.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final notifier = ref.read(catalogProvider.notifier);
      if (notifier.isLoadingMore) return;

      final bool hasMore = ref.read(
        catalogProvider.select(
          (asyncValue) => asyncValue.value?.hasMore ?? false,
        ),
      );
      if (hasMore) {
        notifier.loadMore();
      }
    }
  }

  Widget _buildFilters() {
    return CatalogFilters(
      onLevelChanged: (institutionType) {
        ref
            .read(catalogProvider.notifier)
            .filterByInstitutionType(institutionType);
      },
      onInstitutionChanged: (institutionId) {
        ref.read(catalogProvider.notifier).filterByInstitution(institutionId);
      },
      onSearchSubmitted: (searchText) {
        ref.read(catalogProvider.notifier).search(searchText);
      },
    );
  }

  /// Columns available to the badge grid, which is web only. In sidebar layout
  /// the filters and the layout padding come off the width first.
  int _resolveGridColumns({
    required double contentWidth,
    required bool useSidebarLayout,
  }) {
    if (!PlatformInfo.isWeb) return 0;
    return LayoutConstants.badgeGridColumnCount(
      _gridWidth(
        contentWidth: contentWidth,
        useSidebarLayout: useSidebarLayout,
      ),
      maxColumns: LayoutConstants.catalogGridMaxColumns,
    );
  }

  double _gridWidth({
    required double contentWidth,
    required bool useSidebarLayout,
  }) {
    if (useSidebarLayout) {
      return contentWidth -
          LayoutConstants.sidebarListLayoutPadding * 2 -
          LayoutConstants.sidebarListLayoutSidebarWidth -
          LayoutConstants.sidebarListLayoutColumnGap;
    }
    return contentWidth - LayoutConstants.sidebarListLayoutPadding * 2;
  }

  /// [gridColumns] of 0 renders the single-column list of compact cards.
  List<Widget> _buildBadgeListSlivers({
    required BuildContext context,
    required CatalogState state,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool useSidebarLayout,
    required int gridColumns,
  }) {
    final displayBadges = state.displayBadges;
    final String langCode = ref.watch(appLanguageProvider).code;
    final horizontalPadding = useSidebarLayout
        ? 0.0
        : LayoutConstants.sidebarListLayoutPadding;

    if (displayBadges.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: MergeSemantics(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.search_off,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isSearching
                        ? l10n.catalogNoSearchResults
                        : l10n.catalogNoBadgesAvailable,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: horizontalPadding,
    );
    final Widget loadingSliver = SliverToBoxAdapter(
      child: state.hasMore
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: l10n.semanticsLoading,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );

    if (gridColumns > 0) {
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverLayoutBuilder(
            builder: (BuildContext context, SliverConstraints constraints) {
              // The catalog card carries no chips, so only an issuer that
              // wraps onto a second line makes the tiles taller.
              final int issuerLines = BadgeGridTile.issuerLinesFor(
                context,
                displayBadges.map(
                  (CatalogBadge badge) =>
                      CatalogBadgeCard.issuerNames(badge, langCode),
                ),
                LayoutConstants.badgeGridTileWidth(
                  constraints.crossAxisExtent,
                  gridColumns,
                ),
              );
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  crossAxisSpacing: LayoutConstants.badgeGridSpacing,
                  mainAxisSpacing: LayoutConstants.badgeGridSpacing,
                  mainAxisExtent: LayoutConstants.badgeGridTileHeightFor(
                    chipRows: 0,
                    issuerLines: issuerLines,
                  ),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildBadgeListItem(
                    context: context,
                    badge: displayBadges[index],
                    index: index,
                    useGridTile: true,
                  ),
                  childCount: displayBadges.length,
                ),
              );
            },
          ),
        ),
        loadingSliver,
      ];
    }

    return [
      SliverPadding(
        padding: padding,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildBadgeListItem(
              context: context,
              badge: displayBadges[index],
              index: index,
              useGridTile: false,
            ),
            childCount: displayBadges.length,
          ),
        ),
      ),
      loadingSliver,
    ];
  }

  Widget _buildBadgeListItem({
    required BuildContext context,
    required CatalogBadge badge,
    required int index,
    required bool useGridTile,
  }) {
    void openBadgeDetails() {
      context.push(
        RoutePath.badgeDetailsLocation(
          scope: BadgeDetailsScope.public,
          id: badge.entityId,
        ),
      );
    }

    final Widget item = FocusTraversalOrder(
      order: NumericFocusOrder(index.toDouble()),
      child: KeyboardActivatable(
        key: ValueKey('catalog_badge_${badge.entityId}'),
        wrapWithSemantics: false,
        includeOuterTapTarget: false,
        onActivate: openBadgeDetails,
        child: CatalogBadgeCard(
          badge: badge,
          onTap: openBadgeDetails,
          useGridTile: useGridTile,
        ),
      ),
    );

    if (useGridTile) {
      return item;
    }
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: item);
  }

  Widget _buildCatalogContent({
    required BuildContext context,
    required CatalogState state,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool useSidebarLayout,
    required int gridColumns,
  }) {
    return SidebarListLayout(
      sidebar: _buildFilters(),
      scrollController: _scrollController,
      onRefresh: () => ref.read(catalogProvider.notifier).refresh(),
      useSidebarLayout: useSidebarLayout,
      slivers: _buildBadgeListSlivers(
        context: context,
        state: state,
        l10n: l10n,
        colorScheme: colorScheme,
        textTheme: textTheme,
        useSidebarLayout: useSidebarLayout,
        gridColumns: gridColumns,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final CatalogState? catalogState = catalogAsync.value;
    final bool isCatalogLoading =
        catalogAsync.isLoading && !catalogAsync.hasValue;
    final Object? catalogError = catalogAsync.error;
    final StackTrace? catalogStackTrace = catalogAsync.stackTrace;
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Failures that kept the loaded catalog are surfaced as a snackbar; a
    // failure without data renders ErrorMessageWidget instead.
    ref.listen<AsyncValue<CatalogState>>(catalogProvider, (previous, next) {
      final CatalogFailure? failure = next.value?.failure;
      if (failure == null || failure == previous?.value?.failure) {
        return;
      }
      if (context.mounted) {
        showAppSnackBar(context, l10n.somethingWentWrong);
      }
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useSidebarLayout =
            constraints.maxWidth >= LayoutConstants.sidebarListLayoutMinWidth;
        final int gridColumns = _resolveGridColumns(
          contentWidth: constraints.maxWidth,
          useSidebarLayout: useSidebarLayout,
        );

        return Scaffold(
          appBar: useSidebarLayout
              ? null
              : AppBar(title: Text(l10n.tabCatalog)),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (useSidebarLayout)
                PageHeader(
                  title: l10n.tabCatalog,
                  subtitle: l10n.catalogSubtitle,
                ),
              Expanded(
                child: MaxWidthWrapper(
                  scrollController: _scrollController,
                  maxWidth: useSidebarLayout || gridColumns > 0
                      ? double.infinity
                      : MaxWidthWrapper.defaultMaxWidth,
                  child: GestureDetector(
                    excludeFromSemantics: true,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Builder(
                      builder: (BuildContext context) {
                        if (isCatalogLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              semanticsLabel: l10n.semanticsLoading,
                            ),
                          );
                        }
                        if (catalogError != null && catalogState == null) {
                          return Center(
                            child: ErrorMessageWidget(
                              error: catalogError,
                              stackTrace: catalogStackTrace,
                            ),
                          );
                        }
                        if (catalogState == null) {
                          return const SizedBox.shrink();
                        }
                        return _buildCatalogContent(
                          context: context,
                          state: catalogState,
                          l10n: l10n,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          useSidebarLayout: useSidebarLayout,
                          gridColumns: gridColumns,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
