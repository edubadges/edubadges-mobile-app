import 'package:collection/collection.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/error_message.dart';
import 'package:edubadges/core/widgets/app_back_button.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/primary_button.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/collections/presentation/widgets/collection_action_bar.dart';
import 'package:edubadges/features/collections/presentation/widgets/selectable_badge_list.dart';
import 'package:edubadges/l10n/app_localizations.dart';
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
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedBadgeIds = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
      final badgeInstanceIds =
          await _mergedBadgeInstanceIdsForExistingCollection();
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
        automaticallyImplyLeading: false,
        leading: const AppBackButton(fallbackLocation: RoutePath.collections),
        title: Text(
          l10n.addEdubadges,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(context, l10n, theme, colorScheme, badgesAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    AsyncValue<BadgesOverviewState> badgesAsync,
  ) {
    final Widget badgeList = badgesAsync.when(
      data: (badgesState) {
        final badges = [...badgesState.claimedBadges];

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

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SelectableBadgeSliverList(
                badges: badges,
                selectedBadgeIds: _selectedBadgeIds,
                onToggle: _toggleBadgeSelection,
              ),
            ),
          ],
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
    );

    return Column(
      children: [
        Expanded(
          child: MaxWidthWrapper(
            scrollController: _scrollController,
            child: badgeList,
          ),
        ),
        CollectionActionBar(
          child: PrimaryButton(text: l10n.add, onPressed: _handleCreate),
        ),
      ],
    );
  }
}
