import 'package:collection/collection.dart';
import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/constants/heading_level.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/error_message.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/app_back_button.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/debug_error_log_button.dart';
import 'package:edubadges/core/widgets/lite_rolling_switch.dart';
import 'package:edubadges/core/widgets/loading_spinner.dart';
import 'package:edubadges/core/widgets/sidebar_list_layout.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/collections/data/models/collection_route_model.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:edubadges/shared/presentation/widgets/badge_grid_sliver.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CollectionPage extends ConsumerStatefulWidget {
  final CollectionRouteModel collection;

  const CollectionPage({super.key, required this.collection});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<bool> _publicNotifier;

  /// Whether the copy link button has copied the link. The button then says
  /// so itself, so the confirmation stays readable after the snackbar is gone.
  final ValueNotifier<bool> _linkCopiedNotifier = ValueNotifier<bool>(false);

  CollectionRouteModel get collection => widget.collection;

  @override
  void initState() {
    super.initState();
    _publicNotifier = ValueNotifier<bool>(false);
    _publicNotifier.addListener(_resetLinkCopied);
  }

  @override
  void dispose() {
    _publicNotifier.dispose();
    _linkCopiedNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Called from `build`, so the notifier is only updated after the current
  /// frame and never while the widget tree is being built.
  void _syncPublicNotifier(bool isPublic) {
    if (_publicNotifier.value == isPublic) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _publicNotifier.value = isPublic;
    });
  }

  void _resetLinkCopied() {
    _linkCopiedNotifier.value = false;
  }

  /// The backpack overview's grid on web, as long as two tiles fit; the list
  /// of large cards otherwise.
  Widget _buildBadgeSliver(List<BadgeInstanceEntity> badges) {
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        final int columns = PlatformInfo.isWeb
            ? LayoutConstants.badgeGridColumnCount(
                constraints.crossAxisExtent,
                maxColumns: LayoutConstants.badgesOverviewGridMaxColumns,
              )
            : 0;

        if (columns > 0) {
          return BadgeGridSliver(
            badges: badges,
            columns: columns,
            itemBuilder: (context, index) => BadgeCard(
              instance: badges[index],
              badgeClass: badges[index].badgeclass as BadgeClassModel,
              style: BadgeCardStyle.grid,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final badge = badges[index];
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: BadgeCard(
                instance: badge,
                badgeClass: badge.badgeclass as BadgeClassModel,
                style: BadgeCardStyle.large,
              ),
            );
          }, childCount: badges.length),
        );
      },
    );
  }

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
                child: MergeSemantics(
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
              ),
              const SizedBox(width: 12),
              ValueListenableBuilder<bool>(
                valueListenable: publicNotifier,
                builder: (context, value, child) {
                  final isOn = value && canMakePublic;
                  final onChanged = canMakePublic
                      ? (bool state) async {
                          publicNotifier.value = state;
                          final updateResult = await ref
                              .read(collectionsProvider.notifier)
                              .patchCollection(
                                entityId: collection.entityId,
                                public: state,
                              );
                          updateResult.fold((failure) {
                            publicNotifier.value = !state;
                            if (context.mounted) {
                              showAppSnackBar(
                                context,
                                messageFromFailure(context, failure),
                              );
                            }
                          }, (_) {});
                        }
                      : null;
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
                    semanticLabel:
                        '${l10n.collectionVisibleAndShareable}. '
                        '${isOn ? l10n.semanticsEnabled : l10n.semanticsDisabled}',
                    onChanged: onChanged,
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
              Future<void> copyLink() async {
                final link =
                    '${EnvironmentConfig.instance.publicCollectionBaseUrl}/${collection.entityId}';
                try {
                  await Clipboard.setData(ClipboardData(text: link));
                } catch (e) {
                  if (context.mounted) {
                    showAppSnackBar(context, l10n.somethingWentWrong);
                  }
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                _linkCopiedNotifier.value = true;
                showAppSnackBar(context, l10n.linkCopied);
              }

              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _linkCopiedNotifier,
                      builder: (context, linkCopied, child) {
                        return ElevatedButton.icon(
                          onPressed: copyLink,
                          icon: Icon(
                            linkCopied ? Icons.check : Icons.copy,
                            size: 20,
                          ),
                          label: Text(
                            linkCopied ? l10n.linkCopied : l10n.copyLink,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
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

  Widget _buildCollectionDescription(
    BuildContext context,
    String? description,
  ) {
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        description,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    double screenWidth, {
    String? collectionDescription,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (collectionDescription != null && collectionDescription.isNotEmpty)
          _buildCollectionDescription(context, collectionDescription),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SvgIcon(
                  assetPath: Assets.iconCollections,
                  size: screenWidth / 3,
                  color: colorScheme.primary,
                  excludeFromSemantics: true,
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
                    onPressed: () {
                      context.push(
                        RoutePath.editCollectionPath(id: collection.id),
                      );
                    },
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
                        ExcludeSemantics(
                          child: Icon(
                            Icons.add,
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            (c) => c.entityId == collection.id,
          );
          return foundCollection.name;
        } catch (e) {
          return collection.title;
        }
      },
      loading: () => collection.title,
      error: (error, stackTrace) => collection.title,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isLargeScreen =
            constraints.maxWidth >= LayoutConstants.sidebarListLayoutMinWidth;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            leading: const AppBackButton(
              fallbackLocation: RoutePath.collections,
            ),
            // The app bar makes its title a heading; this sets its level.
            title: Semantics(
              headingLevel: HeadingLevel.page,
              child: Text(
                collectionTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            backgroundColor: AppColors.surface,
            actions: [
              IconButton(
                onPressed: () {
                  context.push(RoutePath.editCollectionPath(id: collection.id));
                },
                icon: const SvgIcon(
                  assetPath: Assets.iconEdit,
                  size: 24,
                  color: AppColors.primary,
                ),
                tooltip: l10n.editCollection,
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
                      // AdaptiveDialog closes itself before calling these, so
                      // popping here would also leave the collection page.
                      onFirstButtonPressed: () {},
                      onSecondButtonPressed: () async {
                        final collectionsAsync = ref.read(collectionsProvider);
                        final List<CollectionsEntity> collections =
                            await collectionsAsync.when(
                              data: (collections) => Future.value(collections),
                              loading: () =>
                                  ref.read(collectionsProvider.future),
                              error: (error, stackTrace) =>
                                  Future.error(error, stackTrace),
                            );

                        if (collections.isEmpty) {
                          if (context.mounted && context.canPop()) {
                            context.pop();
                          }
                          return;
                        }

                        final foundCollection = collections.firstWhereOrNull(
                          (c) => c.entityId == collection.id,
                        );

                        if (foundCollection == null) {
                          if (context.mounted && context.canPop()) {
                            context.pop();
                          }
                          return;
                        }

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
                tooltip: l10n.delete,
              ),
            ],
          ),
          body: collectionsAsync.when(
            data: (collections) {
              final foundCollection = collections.firstWhereOrNull(
                (c) => c.entityId == collection.id,
              );

              if (foundCollection == null) {
                return const ErrorMessageWidget();
              }

              _syncPublicNotifier(foundCollection.public);

              final badges = foundCollection.badgeInstances ?? [];

              if (badges.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildEmptyState(
                    context,
                    MediaQuery.of(context).size.width,
                    collectionDescription: foundCollection.description,
                  ),
                );
              }

              final horizontalPadding = isLargeScreen
                  ? 0.0
                  : LayoutConstants.sidebarListLayoutPadding;

              return SidebarListLayout(
                sidebar: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCollectionDescription(
                      context,
                      foundCollection.description,
                    ),
                    _buildVisibilitySection(
                      context,
                      ref,
                      foundCollection,
                      badges,
                      _publicNotifier,
                    ),
                  ],
                ),
                scrollController: _scrollController,
                onRefresh: () async {
                  return await ref.read(collectionsProvider.notifier).refresh();
                },
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: _buildBadgeSliver(badges),
                  ),
                ],
                useSidebarLayout: isLargeScreen,
              );
            },
            loading: () => const Center(child: LoadingSpinner()),

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
                  DebugErrorLogButton(error: error, stackTrace: stackTrace),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
