import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/app_modal.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/widgets/desktop_badge_claim_dialog.dart';
import 'package:edubadges/features/badges_overview/presentation/widgets/feedback_bottom_sheet.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BadgesOverviewPage extends ConsumerStatefulWidget {
  const BadgesOverviewPage({super.key});

  @override
  ConsumerState<BadgesOverviewPage> createState() => _BadgesOverviewPageState();
}

class _BadgesOverviewPageState extends ConsumerState<BadgesOverviewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFeedbackBottomSheet(BuildContext context) {
    showAppFormModal<void>(
      context,
      useRootNavigator: true,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }

  Widget _buildFeedbackButton({
    required BuildContext context,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
  }) {
    return IconButton(
      icon: ExcludeSemantics(
        child: SvgPicture.asset(
          Assets.iconFeedback,
          colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
        ),
      ),
      onPressed: () => _showFeedbackBottomSheet(context),
      tooltip: l10n.giveFeedback,
    );
  }

  Widget _buildDesktopHeader({
    required AppLocalizations l10n,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.badgesOverviewTitle, style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  l10n.badgesOverviewSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _buildFeedbackButton(
            context: context,
            l10n: l10n,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required BadgeInstanceEntity badge,
    required BadgeDetailsScope scope,
    required String navigationEntityId,
    required VoidCallback onActivate,
    bool showClaimedGalleryOnOpen = false,
  }) {
    final badgeClass = badge.badgeclass as BadgeClassModel;
    return BadgeCard(
      instance: badge,
      badgeClass: badgeClass,
      style: BadgeCardStyle.small,
      showClaimedGalleryOnOpen: showClaimedGalleryOnOpen,
      badgeNavigationScope: scope == BadgeDetailsScope.enrollment
          ? scope
          : null,
      badgeNavigationEntityId: scope == BadgeDetailsScope.enrollment
          ? navigationEntityId
          : null,
      onTap: onActivate,
    );
  }

  Widget _buildBadgeSliver({
    required List<BadgeInstanceEntity> badges,
    required bool isGridLayout,
    required BadgeDetailsScope scope,
    required String keyPrefix,
    required void Function(BadgeInstanceEntity badge) onActivate,
    bool showClaimedGalleryOnOpen = false,
  }) {
    Widget buildItem(BadgeInstanceEntity badge, int index) {
      final navigationEntityId = scope == BadgeDetailsScope.enrollment
          ? badge.badgeclass.entityId
          : badge.entityId;
      void activate() => onActivate(badge);
      return FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: KeyboardActivatable(
          key: ValueKey('${keyPrefix}_${badge.entityId}'),
          wrapWithSemantics: false,
          includeOuterTapTarget: false,
          onActivate: activate,
          child: _buildBadgeCard(
            badge: badge,
            scope: scope,
            navigationEntityId: navigationEntityId,
            onActivate: activate,
            showClaimedGalleryOnOpen: showClaimedGalleryOnOpen,
          ),
        ),
      );
    }

    if (isGridLayout) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: LayoutConstants.badgesOverviewGridCrossAxisCount,
            crossAxisSpacing: LayoutConstants.badgesOverviewGridSpacing,
            mainAxisSpacing: 8,
            mainAxisExtent: LayoutConstants.badgesOverviewGridMainAxisExtent,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildItem(badges[index], index),
            childCount: badges.length,
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: buildItem(badges[index], index),
          ),
          childCount: badges.length,
        ),
      ),
    );
  }

  void _openBadgeDetails({
    required BuildContext context,
    required BadgeDetailsScope scope,
    required String entityId,
  }) {
    context.push(RoutePath.badgeDetailsLocation(scope: scope, id: entityId));
  }

  Widget _buildClaimBannerSliver({
    required BuildContext context,
    required BadgesOverviewState state,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isGridLayout,
  }) {
    final firstBadge = state.unclaimedBadges.first;
    final remainingCount = state.unclaimedBadges.length;

    void onClaimBannerTap() {
      if (isGridLayout) {
        DesktopBadgeClaimDialog.show(
          context: context,
          badgeId: firstBadge.id.toString(),
          remainingCount: remainingCount,
        );
      } else {
        context.push(
          RoutePath.badgeClaimPath(
            id: firstBadge.id.toString(),
            remainingCount: remainingCount,
          ),
        );
      }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: MergeSemantics(
          child: InkWell(
            onTap: onClaimBannerTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: SvgPicture.asset(
                      Assets.iconParty,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.newBadgeReady(state.unclaimedCount),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  ExcludeSemantics(
                    child: SvgPicture.asset(
                      Assets.iconChevron,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                      width: 12,
                      height: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateSliver({
    required String message,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: MergeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: SvgPicture.asset(
                  Assets.iconBackpack,
                  colorFilter: ColorFilter.mode(
                    colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                  width: 48,
                  height: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(message, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody({
    required List<BadgeInstanceEntity> badges,
    required BadgeDetailsScope scope,
    required String keyPrefix,
    required String emptyMessage,
    required bool isGridLayout,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required void Function(BadgeInstanceEntity badge) onActivate,
    Widget? leadingSliver,
    bool showClaimedGalleryOnOpen = false,
  }) {
    return RefreshIndicator(
      backgroundColor: colorScheme.surfaceContainer,
      onRefresh: () async {
        await ref.read(badgesOverviewProvider.notifier).refresh();
      },
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ?leadingSliver,
            if (badges.isEmpty)
              _buildEmptyStateSliver(
                message: emptyMessage,
                colorScheme: colorScheme,
                textTheme: textTheme,
              )
            else ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildBadgeSliver(
                badges: badges,
                isGridLayout: isGridLayout,
                scope: scope,
                keyPrefix: keyPrefix,
                showClaimedGalleryOnOpen: showClaimedGalleryOnOpen,
                onActivate: onActivate,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabbedContent({
    required BuildContext context,
    required BadgesOverviewState state,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isGridLayout,
  }) {
    return Column(
      children: [
        if (isGridLayout)
          _buildDesktopHeader(
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              height: 48,
              text: l10n.badgesTabEarned(state.claimedBadges.length),
            ),
            Tab(
              height: 48,
              text: l10n.badgesTabRequested(state.requestedBadges.length),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTabBody(
                badges: state.claimedBadges,
                scope: BadgeDetailsScope.claimed,
                keyPrefix: 'claimed_badge',
                emptyMessage: l10n.noEdubadgesYet,
                isGridLayout: isGridLayout,
                colorScheme: colorScheme,
                textTheme: textTheme,
                showClaimedGalleryOnOpen: true,
                leadingSliver: state.unclaimedCount > 0
                    ? _buildClaimBannerSliver(
                        context: context,
                        state: state,
                        l10n: l10n,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        isGridLayout: isGridLayout,
                      )
                    : null,
                onActivate: (badge) {
                  _openBadgeDetails(
                    context: context,
                    scope: BadgeDetailsScope.claimed,
                    entityId: badge.entityId,
                  );
                },
              ),
              _buildTabBody(
                badges: state.requestedBadges,
                scope: BadgeDetailsScope.enrollment,
                keyPrefix: 'requested_badge',
                emptyMessage: l10n.noRequestedBadges,
                isGridLayout: isGridLayout,
                colorScheme: colorScheme,
                textTheme: textTheme,
                onActivate: (badge) {
                  _openBadgeDetails(
                    context: context,
                    scope: BadgeDetailsScope.enrollment,
                    entityId: badge.badgeclass.entityId,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgesAsync = ref.watch(badgesOverviewProvider);
    final BadgesOverviewState? badgesState = badgesAsync.value;
    final bool isBadgesLoading = badgesAsync.isLoading && !badgesAsync.hasValue;
    final Object? badgesError = badgesAsync.error;
    final StackTrace? badgesStackTrace = badgesAsync.stackTrace;
    final l10n = AppLocalizations.of(context);

    ref.listen<AsyncValue<BadgesOverviewState>>(badgesOverviewProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (previous?.hasValue == true && context.mounted) {
            showAppSnackBar(context, l10n.somethingWentWrong);
          }
        },
      );
    });
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isGridLayout =
            constraints.maxWidth >= LayoutConstants.badgesOverviewGridMinWidth;

        return Scaffold(
          appBar: isGridLayout
              ? null
              : AppBar(
                  title: SvgPicture.asset(
                    Assets.imageLogo,
                    width: 131,
                    height: 32,
                    semanticsLabel: l10n.appName,
                  ),
                  centerTitle: true,
                  actions: [
                    _buildFeedbackButton(
                      context: context,
                      l10n: l10n,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
          body: Builder(
            builder: (BuildContext context) {
              if (isBadgesLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: l10n.semanticsLoading,
                  ),
                );
              }
              if (badgesError != null && badgesState == null) {
                return Center(
                  child: ErrorMessageWidget(
                    error: badgesError,
                    stackTrace: badgesStackTrace,
                  ),
                );
              }
              if (badgesState == null) {
                return const SizedBox.shrink();
              }
              return _buildTabbedContent(
                context: context,
                state: badgesState,
                l10n: l10n,
                colorScheme: colorScheme,
                textTheme: textTheme,
                isGridLayout: isGridLayout,
              );
            },
          ),
        );
      },
    );
  }
}
