import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/app_modal.dart';
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

class _BadgesOverviewPageState extends ConsumerState<BadgesOverviewPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
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

  Widget _buildDesktopHeaderSliver({
    required AppLocalizations l10n,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
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
      ),
    );
  }

  Widget _buildSectionHeaderSliver({
    required String title,
    required TextTheme textTheme,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Semantics(
          header: true,
          child: Text(title, style: textTheme.titleMedium),
        ),
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
    double focusOrderOffset = 0,
  }) {
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
          delegate: SliverChildBuilderDelegate((context, index) {
            final badge = badges[index];
            final navigationEntityId = scope == BadgeDetailsScope.enrollment
                ? badge.badgeclass.entityId
                : badge.entityId;
            void activate() => onActivate(badge);
            return FocusTraversalOrder(
              order: NumericFocusOrder(focusOrderOffset + index),
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
          }, childCount: badges.length),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final badge = badges[index];
          final navigationEntityId = scope == BadgeDetailsScope.enrollment
              ? badge.badgeclass.entityId
              : badge.entityId;
          void activate() => onActivate(badge);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FocusTraversalOrder(
              order: NumericFocusOrder(focusOrderOffset + index),
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
            ),
          );
        }, childCount: badges.length),
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

  List<Widget> _buildContentSlivers({
    required BuildContext context,
    required BadgesOverviewState state,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isGridLayout,
  }) {
    final slivers = <Widget>[];

    if (isGridLayout) {
      slivers.add(
        _buildDesktopHeaderSliver(
          l10n: l10n,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
      );
    }

    if (state.unclaimedCount > 0) {
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

      final claimBannerLabel = l10n.newBadgeReady(state.unclaimedCount);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: isGridLayout ? 24 : 16,
            ),
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
                          claimBannerLabel,
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
        ),
      );
    }

    if (state.claimedBadges.isNotEmpty) {
      if (isGridLayout) {
        slivers.add(
          _buildSectionHeaderSliver(
            title: l10n.tabBadges,
            textTheme: textTheme,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          ),
        );
      } else {
        slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 16)));
      }
      slivers.add(
        _buildBadgeSliver(
          badges: state.claimedBadges,
          isGridLayout: isGridLayout,
          scope: BadgeDetailsScope.claimed,
          keyPrefix: 'claimed_badge',
          showClaimedGalleryOnOpen: true,
          onActivate: (badge) {
            _openBadgeDetails(
              context: context,
              scope: BadgeDetailsScope.claimed,
              entityId: badge.entityId,
            );
          },
        ),
      );
    }

    if (state.requestedBadges.isNotEmpty) {
      if (state.claimedBadges.isNotEmpty || state.unclaimedCount > 0) {
        slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
      }
      slivers.add(
        _buildSectionHeaderSliver(
          title: l10n.requestedBadges,
          textTheme: textTheme,
        ),
      );
      slivers.add(
        _buildBadgeSliver(
          badges: state.requestedBadges,
          isGridLayout: isGridLayout,
          scope: BadgeDetailsScope.enrollment,
          keyPrefix: 'requested_badge',
          focusOrderOffset: state.claimedBadges.length.toDouble(),
          onActivate: (badge) {
            _openBadgeDetails(
              context: context,
              scope: BadgeDetailsScope.enrollment,
              entityId: badge.badgeclass.entityId,
            );
          },
        ),
      );
    }

    if (state.claimedBadges.isEmpty && state.requestedBadges.isEmpty) {
      slivers.add(
        SliverFillRemaining(
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
                  Text(l10n.noEdubadgesYet, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final BadgesOverviewState? badgesState = ref.watch(
      badgesOverviewProvider.select((asyncValue) => asyncValue.asData?.value),
    );
    final bool isBadgesLoading = ref.watch(
      badgesOverviewProvider.select(
        (asyncValue) => asyncValue.isLoading && !asyncValue.hasValue,
      ),
    );
    final Object? badgesError = ref.watch(
      badgesOverviewProvider.select((asyncValue) => asyncValue.error),
    );
    final StackTrace? badgesStackTrace = ref.watch(
      badgesOverviewProvider.select((asyncValue) => asyncValue.stackTrace),
    );
    final l10n = AppLocalizations.of(context);
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
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Builder(
              builder: (BuildContext context) {
                if (isBadgesLoading) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: AppLocalizations.of(
                              context,
                            ).semanticsLoading,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (badgesError != null) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: ErrorMessageWidget(
                            error: badgesError,
                            stackTrace: badgesStackTrace,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (badgesState == null) {
                  return const SizedBox.shrink();
                }
                final slivers = _buildContentSlivers(
                  context: context,
                  state: badgesState,
                  l10n: l10n,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isGridLayout: isGridLayout,
                );

                return RefreshIndicator(
                  backgroundColor: colorScheme.surfaceContainer,
                  onRefresh: () async {
                    await ref.read(badgesOverviewProvider.notifier).refresh();
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: slivers,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
