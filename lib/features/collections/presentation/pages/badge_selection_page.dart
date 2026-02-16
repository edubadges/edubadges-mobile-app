import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BadgeSelectionPage extends ConsumerStatefulWidget {
  final String name;
  final String? description;

  const BadgeSelectionPage({super.key, required this.name, this.description});

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

  Future<void> _handleCreate() async {
    if (_selectedBadgeIds.isEmpty) {
      final l10n = AppLocalizations.of(context);
      showAppSnackBar(context, l10n.selectAtLeastOneBadge);
      return;
    }

    final success = await ref
        .read(collectionsProvider.notifier)
        .createCollection(
          name: widget.name,
          description: widget.description,
          public: false,
          badgeInstanceIds: _selectedBadgeIds.toList(),
        );

    if (success && mounted) {
      context.go(RoutePath.collections);
    } else if (mounted) {
      final l10n = AppLocalizations.of(context);
      showAppSnackBar(context, l10n.somethingWentWrong);
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
                    ...badgesState.unclaimedBadges,
                    ...badgesState.requestedBadges,
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
                      final isSelected = _selectedBadgeIds.contains(badge.entityId);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _toggleBadgeSelection(badge.entityId),
                          borderRadius: BorderRadius.circular(20),
                          child: BadgeCard(
                            instance: badge,
                            badgeClass: badge.badgeclass as BadgeClassModel,
                            style: BadgeCardStyle.small,
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
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
