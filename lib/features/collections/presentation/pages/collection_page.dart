import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/lite_rolling_switch.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/collections/data/models/collection_route_model.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/collections/presentation/widgets/edit_collection_bottom_sheet.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CollectionPage extends ConsumerWidget {
  final CollectionRouteModel collection;

  const CollectionPage({super.key, required this.collection});

  Widget _buildVisibilitySection(
    BuildContext context,
    WidgetRef ref,
    CollectionsEntity collection,
    List<BadgeInstanceEntity> badges,
    ValueNotifier<bool> publicNotifier,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allBadgesPublic =
        badges.isEmpty || badges.every((badge) => badge.public);
    final canMakePublic = allBadgesPublic && badges.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.collectionVisibleAndShareable,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.publicCollectionRequires,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ValueListenableBuilder<bool>(
                valueListenable: publicNotifier,
                builder: (context, value, child) {
                  final isOn = value && canMakePublic;
                  return AnimatedIconSwitch(
                    value: isOn,
                    width: 44,
                    height: 28,
                    activeColor: colorScheme.primary,
                    inactiveColor: colorScheme.surfaceContainerHighest,
                    activeThumbColor: Colors.white,
                    inactiveThumbColor: colorScheme.onSurfaceVariant,
                    withIcons: true,
                    iconOnThumb: true,
                    activeIcon: Icons.check,
                    inactiveIcon: Icons.close,
                    activeIconColor: colorScheme.primary,
                    inactiveIconColor: Colors.white,
                    activeIconSize: 16,
                    inactiveIconSize: 16,
                    borderRadius: 14,
                    onChanged: canMakePublic
                        ? (bool state) async {
                            publicNotifier.value = state;
                            final success = await ref
                                .read(collectionsProvider.notifier)
                                .updateCollection(
                                  collection.entityId,
                                  collection.name,
                                  collection.description,
                                  state,
                                  collection.badgeInstanceIds
                                      .map((id) => int.tryParse(id) ?? -1)
                                      .where((id) => id != -1)
                                      .toList(),
                                );
                            if (!success) {
                              publicNotifier.value = !state;
                            }
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
          if (!allBadgesPublic && badges.isNotEmpty) ...[
            Text(
              l10n.privateBadgesError,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
          ValueListenableBuilder<bool>(
            valueListenable: publicNotifier,
            builder: (context, isPublicValue, child) {
              if (!isPublicValue || !canMakePublic) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final link =
                            '${EnvironmentConfig.instance.publicCollectionBaseUrl}/${collection.entityId}';
                        Clipboard.setData(ClipboardData(text: link));
                        showAppSnackBar(context, l10n.linkCopied);
                      },
                      icon: const Icon(Icons.copy, size: 20),
                      label: Text(l10n.copyLink),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double screenWidth) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: SvgIcon(
            assetPath: Assets.iconCollections,
            size: screenWidth / 3,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.addEdubadgesToCollection,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.addEdubadgesToCollectionDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: colorScheme.onPrimary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.addEdubadge,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final collectionsAsync = ref.watch(collectionsProvider);

    ref.listen<AsyncValue<List<CollectionsEntity>>>(collectionsProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (context.mounted) {
            showAppSnackBar(context, l10n.somethingWentWrong);
          }
        },
      );
    });

    final collectionTitle = collectionsAsync.when(
      data: (collections) {
        if (collections.isEmpty) return collection.title;
        try {
          final foundCollection = collections.firstWhere(
            (c) => c.id == collection.id,
          );
          return foundCollection.name;
        } catch (e) {
          return collection.title;
        }
      },
      loading: () => collection.title,
      error: (error, stackTrace) => collection.title,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          collectionTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            onPressed: () {
              collectionsAsync.when(
                data: (collections) {
                  try {
                    final foundCollection = collections.firstWhere(
                      (c) => c.id == collection.id,
                    );
                    showModalBottomSheet<void>(
                      context: context,
                      isDismissible: true,
                      enableDrag: true,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => EditCollectionBottomSheet(
                        collection: foundCollection,
                      ),
                    );
                  } catch (e) {
                    if (context.mounted && context.canPop()) {
                      context.pop();
                    }
                  }
                },
                loading: () {},
                error: (error, stackTrace) {},
              );
            },
            icon: const SvgIcon(
              assetPath: Assets.iconEdit,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            onPressed: () {
              AdaptiveDialog.show(
                context: context,
                config: AdaptiveDialogConfig(
                  title: l10n.areYouSure,
                  description: l10n.deleteCollectionConfirmation,
                  firstButtonText: l10n.cancel,
                  secondButtonText: l10n.delete,
                  isDestructiveAction: true,
                  onFirstButtonPressed: () {
                    context.pop();
                  },
                  onSecondButtonPressed: () async {
                    context.pop();
                    final collectionsAsync = ref.read(collectionsProvider);
                    final List<CollectionsEntity> collections = await collectionsAsync.when(
                      data: (collections) => Future.value(collections),
                      loading: () => ref.read(collectionsProvider.future),
                      error: (error, stackTrace) =>
                          Future.error(error, stackTrace),
                    );

                    if (collections.isEmpty) {
                      if (context.mounted && context.canPop()) {
                        context.pop();
                      }
                      return;
                    }

                    final foundCollection = collections.firstWhere(
                      (c) => c.id == collection.id,
                      orElse: () {
                        if (context.mounted && context.canPop()) {
                          context.pop();
                        }
                        throw StateError('Collection not found');
                      },
                    );

                    final success = await ref
                        .read(collectionsProvider.notifier)
                        .deleteCollection(foundCollection.entityId);

                    if (success && context.mounted && context.canPop()) {
                      context.pop();
                    }
                  },
                ),
              );
            },
            icon: const SvgIcon(
              assetPath: Assets.iconDelete,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: MaxWidthWrapper(
        child: collectionsAsync.when(
          data: (collections) {
            try {
              final foundCollection = collections.firstWhere(
                (c) => c.id == collection.id,
              );

              final badges = foundCollection.badgeInstances ?? [];
              final publicNotifier = ValueNotifier<bool>(
                foundCollection.public,
              );

              if (badges.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildEmptyState(
                    context,
                    MediaQuery.of(context).size.width,
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildVisibilitySection(
                    context,
                    ref,
                    foundCollection,
                    badges,
                    publicNotifier,
                  ),
                  ...badges.map(
                    (badge) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: BadgeCard(
                        instance: badge,
                        badgeClass: badge.badgeclass as BadgeClassModel,
                        style: BadgeCardStyle.large,
                      ),
                    ),
                  ),
                ],
              );
            } catch (e) {
              if (context.mounted && context.canPop()) {
                context.pop();
              }
              return const SizedBox.shrink();
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.errorLoadingCollection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.goBack),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
