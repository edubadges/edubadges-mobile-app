import 'package:collection/collection.dart';
import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/error_message.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BadgeSelectionPage extends ConsumerStatefulWidget {
  final String? id;
  final String name;
  final String? description;

  const BadgeSelectionPage({
    super.key,
    this.id,
    required this.name,
    this.description,
  });

  @override
  ConsumerState<BadgeSelectionPage> createState() => _BadgeSelectionPageState();
}

class _BadgeSelectionPageState extends ConsumerState<BadgeSelectionPage> {
  final Set<String> _selectedBadgeIds = {};

  void _toggleBadgeSelection(String badgeEntityId) {
    setState(() {
      if (_selectedBadgeIds.contains(badgeEntityId)) {
        _selectedBadgeIds.remove(badgeEntityId);
      } else {
        _selectedBadgeIds.add(badgeEntityId);
      }
    });
  }

  Future<List<String>> _mergedBadgeInstanceIdsForExistingCollection() async {
    final collectionKey = widget.id!;
    var collections = ref.read(collectionsProvider).asData?.value;
    if (collections == null) {
      try {
        collections = await ref.read(collectionsProvider.future);
      } catch (_) {
        collections = null;
      }
    }

    final CollectionsEntity? current = collections?.firstWhereOrNull(
      (c) => c.entityId == collectionKey,
    );

    final merged = List<String>.from(current?.badgeInstanceIds ?? const []);
    for (final id in _selectedBadgeIds) {
      if (!merged.contains(id)) {
        merged.add(id);
      }
    }
    return merged;
  }

  Future<void> _handleCreate() async {
    if (_selectedBadgeIds.isEmpty) {
      final l10n = AppLocalizations.of(context);
      showAppSnackBar(context, l10n.selectAtLeastOneBadge);
      return;
    }

    if (widget.id != null) {
      final badgeInstanceIds = await _mergedBadgeInstanceIdsForExistingCollection();
      final result = await ref
          .read(collectionsProvider.notifier)
          .patchCollection(
            entityId: widget.id!,
            badgeInstanceIds: badgeInstanceIds,
          );

      if (!mounted) return;
      handleFailureResult(
        context,
        result,
        onSuccess: (_) => context.go(RoutePath.collections),
        snackBarDuration: const Duration(seconds: 5),
      );
    } else {
      final result = await ref
          .read(collectionsProvider.notifier)
          .createCollection(
            name: widget.name,
            description: widget.description,
            public: false,
            badgeInstanceIds: _selectedBadgeIds.toList(),
          );

      if (!mounted) return;
      handleFailureResult(
        context,
        result,
        onSuccess: (_) => context.go(RoutePath.collections),
        snackBarDuration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final badgesAsync = ref.watch(badgesOverviewProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainer,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
          tooltip: l10n.semanticsBack,
        ),
        title: Text(
          l10n.addEdubadges,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: MaxWidthWrapper(
        child: Column(
          children: [
            Expanded(
              child: badgesAsync.when(
                data: (badgesState) {
                  final badges = [
                    ...badgesState.claimedBadges,
                  ];

                  if (badges.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noBadgesAvailable,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      final isSelected = _selectedBadgeIds.contains(
                        badge.entityId,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: KeyboardActivatable(
                          wrapWithSemantics: false,
                          includeOuterTapTarget: false,
                          onActivate: () =>
                              _toggleBadgeSelection(badge.entityId),
                          child: BadgeCard(
                            instance: badge,
                            badgeClass: badge.badgeclass as BadgeClassModel,
                            style: BadgeCardStyle.small,
                            isSelected: isSelected,
                            onTap: () => _toggleBadgeSelection(badge.entityId),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: AppLocalizations.of(
                      context,
                    ).semanticsLoading,
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.somethingWentWrong,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.add,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
