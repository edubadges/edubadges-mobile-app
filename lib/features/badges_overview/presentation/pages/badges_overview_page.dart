import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/widgets/feedback_bottom_sheet.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgesAsync = ref.watch(badgesOverviewProvider);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          Assets.imageLogo,
          width: 131,
          height: 32,
          semanticsLabel: l10n.appName,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ExcludeSemantics(
              child: SvgPicture.asset(
                Assets.iconFeedback,
                colorFilter: ColorFilter.mode(
                  colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            onPressed: () => _showFeedbackBottomSheet(context),
            tooltip: l10n.giveFeedback,
          ),
        ],
      ),
      body: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: MaxWidthWrapper(
          scrollController: _scrollController,
          child: badgesAsync.when(
            data: (state) {
              final slivers = <Widget>[];

              if (state.unclaimedCount > 0) {
                final firstBadge = state.unclaimedBadges.first;
                final remainingCount = state.unclaimedBadges.length;

                void onClaimBannerTap() {
                  context.push(
                    RoutePath.badgeClaimPath(
                      id: firstBadge.id.toString(),
                      remainingCount: remainingCount,
                    ),
                  );
                }

                final claimBannerLabel = l10n.newBadgeReady(
                  state.unclaimedCount,
                );

                slivers.add(
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
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
                slivers.add(
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final badge = state.claimedBadges[index];
                        final badgeClass = badge.badgeclass as BadgeClassModel;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FocusTraversalOrder(
                            order: NumericFocusOrder(index.toDouble()),
                            child: KeyboardActivatable(
                              key: ValueKey('claimed_badge_${badge.entityId}'),
                              wrapWithSemantics: false,
                              includeOuterTapTarget: false,
                              onActivate: () {
                                context.push(
                                  RoutePath.badgeDetailsLocation(
                                    scope: BadgeDetailsScope.claimed,
                                    id: badge.entityId,
                                  ),
                                );
                              },
                              child: BadgeCard(
                                instance: badge,
                                badgeClass: badgeClass,
                                style: BadgeCardStyle.small,
                                showClaimedGalleryOnOpen: true,
                                onTap: () {
                                  context.push(
                                    RoutePath.badgeDetailsLocation(
                                      scope: BadgeDetailsScope.claimed,
                                      id: badge.entityId,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }, childCount: state.claimedBadges.length),
                    ),
                  ),
                );
              }

              if (state.requestedBadges.isNotEmpty) {
                if (state.claimedBadges.isNotEmpty ||
                    state.unclaimedCount > 0) {
                  slivers.add(
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  );
                }
                slivers.add(
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.requestedBadges,
                          style: textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                );
                slivers.add(
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final badge = state.requestedBadges[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: KeyboardActivatable(
                            key: ValueKey('requested_badge_${badge.entityId}'),
                            wrapWithSemantics: false,
                            includeOuterTapTarget: false,
                            onActivate: () {
                              context.push(
                                RoutePath.badgeDetailsLocation(
                                  scope: BadgeDetailsScope.enrollment,
                                  id: badge.badgeclass.entityId,
                                ),
                              );
                            },
                            child: BadgeCard(
                              instance: badge,
                              badgeClass: badge.badgeclass as BadgeClassModel,
                              style: BadgeCardStyle.small,
                              badgeNavigationScope:
                                  BadgeDetailsScope.enrollment,
                              badgeNavigationEntityId:
                                  badge.badgeclass.entityId,
                              onTap: () {
                                context.push(
                                  RoutePath.badgeDetailsLocation(
                                    scope: BadgeDetailsScope.enrollment,
                                    id: badge.badgeclass.entityId,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }, childCount: state.requestedBadges.length),
                    ),
                  ),
                );
              }

              if (state.claimedBadges.isEmpty &&
                  state.requestedBadges.isEmpty) {
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
                            Text(
                              l10n.noEdubadgesYet,
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

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
            loading: () => CustomScrollView(
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
            ),
            error: (error, stackTrace) => CustomScrollView(
              controller: _scrollController,
              slivers: const [
                SliverFillRemaining(child: Center(child: ErrorMessageWidget())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
