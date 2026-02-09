import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_route_from.dart';
import 'package:edubadges/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:edubadges/features/catalog/presentation/widgets/catalog_badge_card.dart';
import 'package:edubadges/features/catalog/presentation/widgets/catalog_filters.dart';
import 'package:edubadges/l10n/app_localizations.dart';
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
      final catalogState = ref.read(catalogProvider);
      if (catalogState.value?.hasMore == true) {
        ref.read(catalogProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabCatalog)),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: MaxWidthWrapper(
          child: catalogAsync.when(
            data: (state) {
              final displayBadges = state.displayBadges;

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 0,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: CatalogFilters(
                        onLevelChanged: (institutionType) {
                          ref
                              .read(catalogProvider.notifier)
                              .filterByInstitutionType(institutionType);
                        },
                        onInstitutionChanged: (institutionId) {
                          ref
                              .read(catalogProvider.notifier)
                              .filterByInstitution(institutionId);
                        },
                        onSearchSubmitted: (searchText) {
                          ref.read(catalogProvider.notifier).search(searchText);
                        },
                      ),
                    ),
                  ),

                  if (displayBadges.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.isSearching
                                  ? l10n.catalogNoSearchResults
                                  : l10n.catalogNoBadgesAvailable,
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < displayBadges.length) {
                              final badge = displayBadges[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: CatalogBadgeCard(
                                  badge: badge,
                                  onTap: () {
                                    final routeModel = BadgeDetailsRouteModel(
                                      id: badge.entityId,
                                      from: BadgeDetailsRouteFrom.catalog,
                                    );
                                    context.push(routeModel.buildRouteUrl());
                                  },
                                ),
                              );
                            } else if (state.hasMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return null;
                          },
                          childCount:
                              displayBadges.length + (state.hasMore ? 1 : 0),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              );
            },
            loading: () => const CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            // TODO: Add error state
            error: (error, stackTrace) => CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
