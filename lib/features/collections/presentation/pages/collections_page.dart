import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/page_header.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAddButton({
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    return IconButton(
      onPressed: () => context.push(RoutePath.newCollection),
      icon: const ExcludeSemantics(
        child: Icon(Icons.add, color: AppColors.primary, size: 24),
      ),
      tooltip: l10n.newCollection,
    );
  }

  Widget _buildCollectionCard({
    required BuildContext context,
    required CollectionsEntity collection,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required AppLocalizations l10n,
  }) {
    final badges = collection.badgeInstances ?? [];
    final badgeCount = badges.length;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: MergeSemantics(
        child: InkWell(
          onTap: () {
            context.push(
              RoutePath.collectionPath(
                id: collection.entityId,
                title: collection.name,
                description: collection.description,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildBadgeGrid(badges, badgeCount, colorScheme),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        collection.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.countEdubadges(badgeCount),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionSliver({
    required List<CollectionsEntity> collections,
    required bool isGridLayout,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required AppLocalizations l10n,
  }) {
    if (isGridLayout) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: LayoutConstants.collectionsGridCrossAxisCount,
            crossAxisSpacing: LayoutConstants.badgesOverviewGridSpacing,
            mainAxisSpacing: 16,
            mainAxisExtent: LayoutConstants.collectionsGridMainAxisExtent,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            return _buildCollectionCard(
              context: context,
              collection: collections[index],
              colorScheme: colorScheme,
              textTheme: textTheme,
              l10n: l10n,
            );
          }, childCount: collections.length),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCollectionCard(
              context: context,
              collection: collections[index],
              colorScheme: colorScheme,
              textTheme: textTheme,
              l10n: l10n,
            ),
          );
        }, childCount: collections.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final collectionsAsync = ref.watch(collectionsProvider);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isGridLayout =
            constraints.maxWidth >= LayoutConstants.badgesOverviewGridMinWidth;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: isGridLayout
              ? null
              : AppBar(
                  title: Text(l10n.tabCollections),
                  backgroundColor: AppColors.surface,
                  actions: [_buildAddButton(context: context, l10n: l10n)],
                ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isGridLayout)
                PageHeader(
                  title: l10n.tabCollections,
                  actions: [_buildAddButton(context: context, l10n: l10n)],
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                ),
              Expanded(
                child: MaxWidthWrapper(
                  scrollController: _scrollController,
                  // The grid spans the full content pane like the design;
                  // only the compact list is capped so rows do not stretch
                  // across a wide window.
                  maxWidth: isGridLayout
                      ? double.infinity
                      : MaxWidthWrapper.defaultMaxWidth,
                  child: RefreshIndicator(
                    backgroundColor: colorScheme.surfaceContainer,
                    onRefresh: () async {
                      await ref.read(collectionsProvider.notifier).refresh();
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        ...collectionsAsync.when(
                          data: (collections) {
                            if (collections.isEmpty) {
                              return [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgIcon(
                                          assetPath: Assets.iconCollections,
                                          size: 40,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.noCollectionsYet,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ];
                            }
                            return [
                              _buildCollectionSliver(
                                collections: collections,
                                isGridLayout: isGridLayout,
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                                l10n: l10n,
                              ),
                            ];
                          },
                          loading: () => [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: CircularProgressIndicator(
                                  semanticsLabel: l10n.semanticsLoading,
                                ),
                              ),
                            ),
                          ],
                          error: (error, stackTrace) => [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      l10n.errorLoadingCollections,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(color: colorScheme.error),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () => ref
                                          .read(collectionsProvider.notifier)
                                          .refresh(),
                                      child: Text(l10n.retry),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildBadgeGrid(
    List<BadgeInstanceEntity> badges,
    int badgeCount,
    ColorScheme colorScheme,
  ) {
    final badgesToShow = badges.take(3).toList();
    final showMoreBox = badgeCount > 4;
    final remainingCount = badgeCount - 3;

    return GridView.builder(
      // Each card has its own small grid. Without this, every grid attaches to
      // the page's PrimaryScrollController (MaxWidthWrapper) on mobile, and the
      // page scrollbar asserts that its controller has several positions.
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: badgesToShow.length + (showMoreBox ? 1 : 0),
      itemBuilder: (context, index) {
        final l10n = AppLocalizations.of(context);
        if (index == 3 && showMoreBox) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          );
        }

        if (index < badgesToShow.length) {
          final badge = badgesToShow[index];
          final badgeImageUrl = buildImageUrl(badge.badgeclass.image);

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: badgeImageUrl != null
                ? AppNetworkImage(
                    imageUrl: badgeImageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    semanticLabel: l10n.semanticsBadgeImage,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      );
                    },
                  )
                : Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                      semanticLabel: l10n.semanticsImageNotSupported,
                    ),
                  ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
