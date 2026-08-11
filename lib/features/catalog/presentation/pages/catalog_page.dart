import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:edubadges/core/widgets/page_header.dart';
import 'package:edubadges/core/widgets/sidebar_list_layout.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_state.dart';
import 'package:edubadges/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:edubadges/features/catalog/presentation/widgets/catalog_badge_card.dart';
import 'package:edubadges/features/catalog/presentation/widgets/catalog_filters.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
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

  List<Widget> _buildBadgeListSlivers({
    required BuildContext context,
    required CatalogState state,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool useSidebarLayout,
  }) {
    final displayBadges = state.displayBadges;
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

    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index < displayBadges.length) {
              return _buildBadgeListItem(
                context: context,
                badge: displayBadges[index],
                index: index,
              );
            } else if (state.hasMore) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: l10n.semanticsLoading,
                  ),
                ),
              );
            }
            return null;
          }, childCount: displayBadges.length + (state.hasMore ? 1 : 0)),
        ),
      ),
    ];
  }

  Widget _buildBadgeListItem({
    required BuildContext context,
    required CatalogBadge badge,
    required int index,
  }) {
    void openBadgeDetails() {
      context.push(
        RoutePath.badgeDetailsLocation(
          scope: BadgeDetailsScope.public,
          id: badge.entityId,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: KeyboardActivatable(
          key: ValueKey('catalog_badge_${badge.entityId}'),
          wrapWithSemantics: false,
          includeOuterTapTarget: false,
          onActivate: openBadgeDetails,
          child: CatalogBadgeCard(badge: badge, onTap: openBadgeDetails),
        ),
      ),
    );
  }

  Widget _buildCatalogContent({
    required BuildContext context,
    required CatalogState state,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool useSidebarLayout,
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

    ref.listen<AsyncValue<CatalogState>>(catalogProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (previous?.hasValue == true && context.mounted) {
            showAppSnackBar(context, l10n.somethingWentWrong);
          }
        },
      );
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useSidebarLayout =
            constraints.maxWidth >= LayoutConstants.sidebarListLayoutMinWidth;

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
                      );
                    },
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
