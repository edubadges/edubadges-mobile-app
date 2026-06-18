import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/collections/presentation/widgets/create_collection_bottom_sheet.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  void _showCreateCollectionBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateCollectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final collectionsAsync = ref.watch(collectionsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.tabCollections),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            onPressed: () => _showCreateCollectionBottomSheet(context),
            icon: const ExcludeSemantics(
              child: Icon(Icons.add, color: AppColors.primary, size: 24),
            ),
            tooltip: l10n.newCollection,
          ),
        ],
      ),
      body: MaxWidthWrapper(
        child: collectionsAsync.when(
          data: (collections) {
            return RefreshIndicator(
              backgroundColor: colorScheme.surfaceContainer,
              onRefresh: () async {
                await ref.read(collectionsProvider.notifier).refresh();
              },
              child: collections.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgIcon(
                                  assetPath: Assets.iconCollections,
                                  size: 40,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noCollectionsYet,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: collections.length,
                      itemBuilder: (context, index) {
                        final collection = collections[index];
                        final badges = collection.badgeInstances ?? [];
                        final badgeCount = badges.length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
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
                                        child: _buildBadgeGrid(
                                          badges,
                                          badgeCount,
                                          colorScheme,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            collection.name,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            l10n.countEdubadges(badgeCount),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
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
                      },
                    ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context).semanticsLoading,
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.errorLoadingCollections,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(collectionsProvider.notifier).refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
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
                ? Image.network(
                    badgeImageUrl,
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
